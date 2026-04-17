locals {
  project     = "keycloak"
  environment = "dev"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
  }

  ecr_repositories = {
    nginx = "nginx"
    app   = "app"
  }

}