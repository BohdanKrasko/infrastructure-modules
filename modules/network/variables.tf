variable "vpc_name" {
  type = string
}
variable "igw_name" {
  type = string
}
variable "cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "cloudfront_domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "aws_lb_target_group" {
  type = string
}
variable "aws_lb_name" {
  type    = string
}

variable "aws_service_discovery_private_dns_namespace_go_name" {
  type = string
  description = "was todo"
}

variable "aws_service_discovery_service_mongo_name" {
  type = string
  description = "was mongo"
}

variable "aws_ecs_cluster_name" {
  type = string
  description = "was todo"
}

variable "aws_ecs_task_definition_go_family" {
  type = string
  description = "was go"
}

variable "aws_ecs_task_definition_mongo_family" {
  type = string
  description = "was mongo"
}

variable "aws_ecs_service_go_name" {
  type = string
  description = "was go"
}

variable "aws_ecs_service_mongo_name" {
  type = string
  description = "was mongo"
}

variable "aws_route53_record_go_name" {
  type = string
  description = "was go.ekstodoapp.tk"
  
}

variable "aws_route53_record_clodfront_name" {
  type = string
  description = "www.ekstodoapp.tk"
}
variable "acm_certificate_arn" {
  type = string
}

variable "prod_json_go" {
  type = string
}

variable "go_image" {
  type = string
}