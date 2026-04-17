output "service_id" {
  description = "Keycloak ECS service ID"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "Keycloak ECS service name"
  value       = aws_ecs_service.this.name
}