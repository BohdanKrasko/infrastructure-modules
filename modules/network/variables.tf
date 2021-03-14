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
  type = string
}

variable "aws_route53_record_go_name" {
  type        = string
  description = "was go.ekstodoapp.tk"

}

variable "aws_route53_record_clodfront_name" {
  type        = string
  description = "www.ekstodoapp.tk"
}
variable "acm_certificate_arn" {
  type = string
}

variable "public_hosted_zone_id" {
  type = string
}