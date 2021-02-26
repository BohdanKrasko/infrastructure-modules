module "s3" {
  source = "./modules/s3"
  s3_bucket_name = var.s3_bucket_name
  go_server = var.aws_route53_record_go_name
}

module "network" {
  source          = "./modules/network"
  vpc_name        = var.vpc_name
  igw_name        = var.igw_name
  cidr            = var.cidr
  public_subnets  = var.public_subnets
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  hosted_zone_id = module.cloudfront.hosted_zone_id
  aws_lb_target_group = var.aws_lb_target_group
  aws_lb_name = var.aws_lb_name
  aws_service_discovery_private_dns_namespace_go_name = var.aws_service_discovery_private_dns_namespace_go_name
  aws_service_discovery_service_mongo_name = var.aws_service_discovery_service_mongo_name
  aws_ecs_cluster_name = var.aws_ecs_cluster_name
  aws_ecs_task_definition_go_family = var.aws_ecs_task_definition_go_family
  aws_ecs_task_definition_mongo_family = var.aws_ecs_task_definition_mongo_family
  aws_ecs_service_go_name =  var.aws_ecs_service_go_name
  aws_ecs_service_mongo_name = var.aws_ecs_service_mongo_name
  aws_route53_record_go_name = var.aws_route53_record_go_name
  aws_route53_record_clodfront_name = var.aws_route53_record_clodfront_name
  acm_certificate_arn = var.acm_certificate_arn
  prod_json_go = var.prod_json_go

}

module "cloudfront" {
  source = "./modules/cloudfront"
  domain_name = var.aws_route53_record_clodfront_name
  acm_certificate_arn = var.acm_certificate_arn
  s3_website_endpoint = module.s3.s3_website_endpoint
}