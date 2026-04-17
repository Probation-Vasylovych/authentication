output "service_connect_namespace_name" {
  description = "Service Connect namespace name"
  value       = aws_service_discovery_http_namespace.this.name
}

output "service_connect_namespace_arn" {
  description = "Service Connect namespace ARN"
  value       = aws_service_discovery_http_namespace.this.arn
}

output "service_connect_namespace_id" {
  description = "Service Connect namespace ID"
  value       = aws_service_discovery_http_namespace.this.id
}