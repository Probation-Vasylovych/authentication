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

module "ecs_iam" {
  source = "./modules/ecs-iam"

  project     = var.project
  env         = var.env
  common_tags = local.common_tags
  secrets_manager_secret_arns = [
    module.oauth2_proxy_secrets.secret_arn
  ]
}

module "ecs_task_keycloak" {
  source = "./modules/ecs-task-keycloak"

  project    = var.project
  env        = var.env
  aws_region = var.region

  domain_name = var.domain_name

  keycloak_image          = "quay.io/keycloak/keycloak:26.2"
  keycloak_admin_username = "admin"
  keycloak_admin_password = var.keycloak_admin_password

  execution_role_arn = module.ecs_iam.task_execution_role_arn
  task_role_arn      = module.ecs_iam.task_role_arn

  common_tags = local.common_tags
}

module "ecs_service_keycloak" {
  source = "./modules/ecs-service-keycloak"

  project = var.project
  env     = var.env

  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_keycloak.task_definition_arn

  private_subnet_ids = module.vpc_config.private_fargate_subnet_ids
  security_group_id  = module.security_groups.keycloak_service_security_group_id
  target_group_arn   = module.alb.keycloak_target_group_arn

  container_name = module.ecs_task_keycloak.container_name
  container_port = module.ecs_task_keycloak.container_port

  service_connect_namespace_arn = module.service_connect.service_connect_namespace_arn

  common_tags = local.common_tags
}

module "oauth2_proxy_secrets" {
  source = "./modules/oauth2-proxy-secrets"

  project                    = var.project
  env                        = var.env
  oauth2_proxy_client_secret = var.oauth2_proxy_client_secret
  common_tags                = local.common_tags
}

module "ecs_task_app" {
  source = "./modules/ecs-task-app"

  project    = var.project
  env        = var.env
  aws_region = var.region

  app_image = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/app:latest"

  execution_role_arn = module.ecs_iam.task_execution_role_arn
  task_role_arn      = module.ecs_iam.task_role_arn

  common_tags = local.common_tags
}

module "ecs_service_app" {
  source = "./modules/ecs-service-app"

  project = var.project
  env     = var.env

  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_app.task_definition_arn

  private_subnet_ids = module.vpc_config.private_fargate_subnet_ids
  security_group_id  = module.security_groups.app_service_security_group_id

  service_connect_namespace_arn = module.service_connect.service_connect_namespace_arn

  common_tags = local.common_tags
}

module "ecs_task_edge" {
  source = "./modules/ecs-task-edge"

  project    = var.project
  env        = var.env
  aws_region = var.region

  domain_name             = var.domain_name
  keycloak_realm          = var.keycloak_realm
  oauth2_proxy_client_id  = var.oauth2_proxy_client_id
  oauth2_proxy_secret_arn = module.oauth2_proxy_secrets.secret_arn

  nginx_image        = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/nginx:latest"
  oauth2_proxy_image = "quay.io/oauth2-proxy/oauth2-proxy:v7.12.0"

  execution_role_arn = module.ecs_iam.task_execution_role_arn
  task_role_arn      = module.ecs_iam.task_role_arn

  common_tags = local.common_tags
}

module "ecs_service_edge" {
  source = "./modules/ecs-service-edge"

  project = var.project
  env     = var.env

  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_edge.task_definition_arn

  private_subnet_ids = module.vpc_config.private_fargate_subnet_ids
  security_group_id  = module.security_groups.edge_service_security_group_id

  target_group_arn = module.alb.edge_target_group_arn
  container_name   = module.ecs_task_edge.nginx_container_name
  container_port   = module.ecs_task_edge.nginx_container_port

  service_connect_namespace_arn = module.service_connect.service_connect_namespace_arn

  common_tags = local.common_tags

  depends_on = [
    module.ecs_service_app
  ]
}