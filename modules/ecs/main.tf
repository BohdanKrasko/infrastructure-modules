resource "aws_service_discovery_private_dns_namespace" "go" {
  name = var.aws_service_discovery_private_dns_namespace_go_name
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "mongo" {
  name = var.aws_service_discovery_service_mongo_name

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


resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}_ecs_task_role"
  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite", "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}



resource "aws_ecs_cluster" "todo" {
  name               = var.aws_ecs_cluster_name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "mongo" {
  family                = var.aws_ecs_task_definition_mongo_family
  container_definitions = file("mongo.json")
  network_mode          = "awsvpc"
  execution_role_arn    = aws_iam_role.ecs_task_role.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_task_definition" "go" {
  family                = var.aws_ecs_task_definition_go_family
  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "go",
    "repositoryCredentials": {
      "credentialsParameter": "${var.secret_manager_arn}"
    },
    "image": "${var.go_image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "environment": [
      {
        "name": "DB_URI",
        "value": "mongodb://mongo.${var.env}-todo:27017/?compressors=disabled&gssapiServiceName=mongodb"
      }
    ]
  }
]
TASK_DEFINITION
  network_mode          = "awsvpc"
  execution_role_arn    = aws_iam_role.ecs_task_role.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "mongo" {
  name                               = var.aws_ecs_service_mongo_name
  cluster                            = aws_ecs_cluster.todo.id
  task_definition                    = aws_ecs_task_definition.mongo.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    security_groups  = [aws_security_group.mongo_sg.id]
    assign_public_ip = true
    subnets          = var.subnets
  }

  launch_type = "FARGATE"

  lifecycle {
    ignore_changes = [desired_count, tags]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mongo.arn
  }
}

resource "aws_ecs_service" "go" {
  name                               = var.aws_ecs_service_go_name
  cluster                            = aws_ecs_cluster.todo.id
  task_definition                    = aws_ecs_task_definition.go.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = var.aws_lb_target_group_go_arn
    container_name   = "go"
    container_port   = 8080
  }

  network_configuration {
    security_groups  = [aws_security_group.go_sg.id]
    assign_public_ip = true
    subnets          = var.subnets
  }

  launch_type = "FARGATE"

  lifecycle {
    ignore_changes = [desired_count, tags]
  }

  depends_on = [
    module.network
  ]
}