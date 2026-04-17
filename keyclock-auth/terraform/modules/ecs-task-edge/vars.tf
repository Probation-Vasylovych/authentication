variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "keycloak_realm" {
  type = string
}

variable "oauth2_proxy_client_id" {
  type = string
}

variable "oauth2_proxy_secret_arn" {
  type = string
}

variable "nginx_image" {
  type = string
}

variable "oauth2_proxy_image" {
  type    = string
  default = "quay.io/oauth2-proxy/oauth2-proxy:v7.12.0"
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)
}