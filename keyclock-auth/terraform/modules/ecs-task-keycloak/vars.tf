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

variable "keycloak_image" {
  type    = string
  default = "quay.io/keycloak/keycloak:26.2"
}

variable "keycloak_admin_username" {
  type    = string
  default = "admin"
}

variable "keycloak_admin_password" {
  type      = string
  sensitive = true
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