module "vpc" {
  source = "./modules/vpc"

  project     = var.project
  env         = var.env
  common_tags = local.common_tags
}

module "vpc_config" {
  source = "./modules/vpc-config"

  env         = var.env
  vpc_id      = module.vpc.vpc_id
  subnets     = var.subnets
  common_tags = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  repositories       = local.ecr_repositories
  push_principal_arn = module.github_oidc_ecr.role_arn
  common_tags        = local.common_tags
}

module "github_oidc_ecr" {
  source = "./modules/github-oidc-ecr"

  github_org           = var.github_org
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  aws_region           = var.region
  aws_account_id       = var.aws_account_id
  ecr_repository_names = local.ecr_repositories
  common_tags          = local.common_tags
}


module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  env         = var.env
  project     = var.project
  common_tags = local.common_tags
}

module "security_groups" {
  source = "./modules/security-groups"

  project = var.project
  env     = var.env
  vpc_id  = module.vpc.vpc_id

  common_tags = local.common_tags
}

module "dns" {
  source = "./modules/dns"

  env         = var.env
  project     = var.project
  domain_name = var.domain_name
  common_tags = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  project = var.project
  env     = var.env

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc_config.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  acm_certificate_arn   = module.dns.certificate_arn
  domain_name           = var.domain_name
  common_tags           = local.common_tags
}

module "service_connect" {
  source = "./modules/service-connect"

  project     = var.project
  env         = var.env
  common_tags = local.common_tags
}

module "route53_records" {
  source = "./modules/route53-records"

  hosted_zone_id = module.dns.zone_id
  domain_name    = var.domain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
}