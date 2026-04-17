variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "secrets_manager_secret_arns" {
  description = "List of Secrets Manager secret ARNs that ECS task execution role can read"
  type        = list(string)
  default     = []
}