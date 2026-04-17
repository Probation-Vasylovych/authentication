variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "oauth2_proxy_client_secret" {
  type      = string
  sensitive = true
}

variable "common_tags" {
  type = map(string)
}