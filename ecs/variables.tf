variable "vpc_name" {
  type    = string
  default = "vpc"
}

variable "igw_name" {
  type    = string
  default = "igw"
}
variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]
}

variable "aws_lb_target_group" {
  type = string
  default = "prod-target-group"
}
variable "aws_lb_name" {
  type    = string
  default = "prod-lb-name"
}

variable "aws_service_discovery_private_dns_namespace_go_name" {
  type = string
  description = "was todo"
  default = "prod-todo"
}

variable "aws_service_discovery_service_mongo_name" {
  type = string
  description = "was mongo"
  default = "mongo"
}

variable "aws_ecs_cluster_name" {
  type = string
  description = "was todo"
  default = "prod-todo"
}

variable "aws_ecs_task_definition_go_family" {
  type = string
  description = "was go"
  default = "prod-go"
}

variable "aws_ecs_task_definition_mongo_family" {
  type = string
  description = "was mongo"
  default = "prod-mongo"
}

variable "aws_ecs_service_go_name" {
  type = string
  description = "was go"
  default = "prod-go"
}

variable "aws_ecs_service_mongo_name" {
  type = string
  description = "was mongo"
  default = "prod-mongo"
}

variable "aws_route53_record_go_name" {
  type = string
  description = "was go.ekstodoapp.tk"
  default = "go.ekstodoapp.tk"
  
}

variable "aws_route53_record_clodfront_name" {
  type = string
  description = "www.ekstodoapp.tk"
  default = "prod.ekstodoapp.tk"
}

variable "acm_certificate_arn" {
  type = string
  default = "arn:aws:acm:us-east-1:882500013896:certificate/fbfa39bf-bdff-43d2-b750-e2d013582462"
}

variable "prod_json_go" {
  type = string
  default = "prod_go.json"
}

