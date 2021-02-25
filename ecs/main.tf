module "network" {
  source          = "./modules/network"
  vpc_name        = var.vpc_name
  igw_name        = var.igw_name
  cidr            = var.cidr
  public_subnets  = var.public_subnets
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  hosted_zone_id = module.cloudfront.hosted_zone_id

}

module "cloudfront" {
  source = "./modules/cloudfront"
  domain_name = "www.ekstodoapp.tk"
}