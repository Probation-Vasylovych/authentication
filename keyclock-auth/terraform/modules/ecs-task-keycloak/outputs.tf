output "task_definition_arn" {
  description = "Keycloak task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "container_name" {
  description = "Keycloak container name"
  value       = "keycloak"
}

output "container_port" {
  description = "Keycloak container port"
  value       = 8080
}