variable "region" {
  description = "Region where resource will be created"
  type        = string
}

variable "vpc_name" {
  type = string
}

variable "env" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
    type              = string
  }))
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "aws_account_id" {
  type = number
}

variable "project" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "keycloak_admin_password" {
  type      = string
  sensitive = true
}

variable "oauth2_proxy_client_secret" {
  type      = string
  sensitive = true
}

variable "keycloak_realm" {
  type = string

}

variable "oauth2_proxy_client_id" {
  type = string

}