variable "vpc_id" {
  type    = string
}

variable "subnets" {
  type = string
}
variable "env" {
  type    = string
}

variable "aws_ecs_cluster_name" {
  type        = string
  description = "was todo"
}

variable "aws_service_discovery_private_dns_namespace_go_name" {
  type        = string
  description = "was todo"
}

variable "aws_ecs_task_definition_go_family" {
  type        = string
  description = "was go"
}

variable "aws_ecs_task_definition_mongo_family" {
  type        = string
  description = "was mongo"
}

variable "secret_manager_arn" {
  type = string
}

variable "go_image" {
  type = string
}

variable "aws_ecs_service_go_name" {
  type        = string
  description = "was go"
}

variable "aws_ecs_service_mongo_name" {
  type        = string
  description = "was mongo"
}

variable "aws_lb_target_group_go_arn" {
  type        = string
}

variable "aws_service_discovery_service_mongo_name" {
  type = string
}
