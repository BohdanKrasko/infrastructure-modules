module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = var.s3_bucket_name
  go_server      = var.aws_route53_record_go_name
}

module "network" {
  source                            = "./modules/network"
  vpc_name                          = var.vpc_name
  igw_name                          = var.igw_name
  cidr                              = var.cidr
  public_subnets                    = var.public_subnets
  cloudfront_domain_name            = module.cloudfront.cloudfront_domain_name
  hosted_zone_id                    = module.cloudfront.hosted_zone_id
  aws_lb_target_group               = var.aws_lb_target_group
  aws_lb_name                       = var.aws_lb_name
  aws_route53_record_go_name        = var.aws_route53_record_go_name
  aws_route53_record_clodfront_name = var.aws_route53_record_clodfront_name
  acm_certificate_arn               = var.acm_certificate_arn
  public_hosted_zone_id             = var.public_hosted_zone_id
}

module "ecs" {
  source                                              = "./modules/ecs"
  vpc_id                                              = module.network.vpc_id
  subnets                                             = module.network.public_subnets
  aws_service_discovery_service_mongo_name            = var.aws_service_discovery_service_mongo_name
  aws_ecs_cluster_name                                = var.aws_ecs_cluster_name
  env                                                 = var.env
  aws_ecs_task_definition_go_family                   = var.aws_ecs_task_definition_go_family
  aws_ecs_task_definition_mongo_family                = var.aws_ecs_task_definition_mongo_family
  secret_manager_arn                                  = var.secret_manager_arn
  go_image                                            = var.go_image
  aws_ecs_service_go_name                             = var.aws_ecs_service_go_name
  aws_ecs_service_mongo_name                          = var.aws_ecs_service_mongo_name
  aws_service_discovery_private_dns_namespace_go_name = var.aws_service_discovery_private_dns_namespace_go_name
  aws_lb_target_group_go_arn                          = module.network.aws_lb_target_group_go_arn
  aws_lb_go                                           = module.network.aws_lb_go
}

module "cloudfront" {
  source              = "./modules/cloudfront"
  domain_name         = var.aws_route53_record_clodfront_name
  acm_certificate_arn = var.acm_certificate_arn
  s3_website_endpoint = module.s3.s3_website_endpoint
  lambda_arn          = var.lambda_arn
}