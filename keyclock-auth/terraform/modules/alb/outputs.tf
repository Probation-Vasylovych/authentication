output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.this.zone_id
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = aws_lb_listener.https.arn
}

output "edge_target_group_arn" {
  description = "Target group ARN for edge ECS service"
  value       = aws_lb_target_group.edge.arn
}

output "keycloak_target_group_arn" {
  description = "Target group ARN for Keycloak ECS service"
  value       = aws_lb_target_group.keycloak.arn
}