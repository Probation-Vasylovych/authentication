output "alb_security_group_id" {
  description = "Security group ID for the public ALB"
  value       = aws_security_group.alb.id
}

output "edge_service_security_group_id" {
  description = "Security group ID for ECS edge service: nginx + oauth2-proxy"
  value       = aws_security_group.edge_service.id
}

output "keycloak_service_security_group_id" {
  description = "Security group ID for ECS Keycloak service"
  value       = aws_security_group.keycloak_service.id
}

output "app_service_security_group_id" {
  description = "Security group ID for ECS application service"
  value       = aws_security_group.app_service.id
}