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
  name        = var.aws_lb_target_group
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    path = "/api/task"
  }
}


resource "aws_lb" "go" {
  name               = var.aws_lb_name
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
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.go.arn
  }
}



resource "aws_route53_record" "go" {
  zone_id = var.public_hosted_zone_id
  name    = var.aws_route53_record_go_name
  type    = "A"

  alias {
    name                   = aws_lb.go.dns_name
    zone_id                = aws_lb.go.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "clodfront" {
  zone_id = var.public_hosted_zone_id
  name    = var.aws_route53_record_clodfront_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.hosted_zone_id
    evaluate_target_health = true
  }
}