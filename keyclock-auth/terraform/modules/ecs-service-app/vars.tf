variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "service_connect_namespace_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)
}