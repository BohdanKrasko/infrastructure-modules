data "aws_vpc" "selected" {
  id = aws_vpc.vpc.id
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = "Public"
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-%d", count.index)
    Tier = "Public"
  }

}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route-table-public"
  }
}

resource "aws_route_table_association" "subnet-association-public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.route-table.id
}

resource "aws_lb_target_group" "go" {
  name        = "go-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    path = "/api/task"
  }
}


resource "aws_lb" "go" {
  name               = "go"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false
}

resource "aws_lb_listener" "go" {
  load_balancer_arn = aws_lb.go.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.go.arn
  }
}

resource "aws_lb_listener" "go-https" {
  load_balancer_arn = aws_lb.go.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:882500013896:certificate/53cd4f95-c9aa-48a4-a222-a7c4d49246e6"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.go.arn
  }
}

resource "aws_service_discovery_private_dns_namespace" "go" {
  name        = "todo"
  vpc         = aws_vpc.vpc.id
}

resource "aws_service_discovery_service" "mongo" {
  name = "mongo"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.go.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}






resource "aws_ecs_cluster" "todo" {
  name = "todo"
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "mongo" {
  family                = "mongo"
  container_definitions = file("mongo.json")
  network_mode = "awsvpc"
  execution_role_arn = "arn:aws:iam::882500013896:role/ecsTaskExecutionRole"
  
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
}

resource "aws_ecs_task_definition" "go" {
  family                = "go"
  container_definitions = file("go.json")
  network_mode = "awsvpc"
  execution_role_arn = "arn:aws:iam::882500013896:role/ecsTaskExecutionRole"
  
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
}

resource "aws_ecs_service" "mongo" {
  name            = "mongo"
  cluster         = aws_ecs_cluster.todo.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    security_groups = [aws_security_group.mongo_sg.id]
    assign_public_ip = true
    subnets = aws_subnet.public.*.id
  }

  launch_type = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.mongo.arn
  }
}

resource "aws_ecs_service" "go" {
  name            = "go"
  cluster         = aws_ecs_cluster.todo.id
  task_definition = aws_ecs_task_definition.go.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.go.arn
    container_name   = "go"
    container_port   = 8080
  }

  network_configuration {
    security_groups = [aws_security_group.go_sg.id]
    assign_public_ip = true
    subnets = aws_subnet.public.*.id
  }

  launch_type = "FARGATE"

  depends_on = [
    aws_lb.go, 
    aws_lb_target_group.go
  ]
}

resource "aws_route53_record" "go" {
  zone_id = "Z05340611QTGXY4HN6R2I"
  name    = "go.ekstodoapp.tk"
  type    = "A"

  alias {
    name                   = aws_lb.go.dns_name
    zone_id                = aws_lb.go.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "clodfront" {
  zone_id = "Z05340611QTGXY4HN6R2I"
  name    = "www.ekstodoapp.tk"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.hosted_zone_id
    evaluate_target_health = true
  }
}