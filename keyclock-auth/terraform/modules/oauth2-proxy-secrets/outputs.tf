output "secret_arn" {
  description = "Secrets Manager ARN for oauth2-proxy secrets"
  value       = aws_secretsmanager_secret.oauth2_proxy.arn
}

output "secret_name" {
  description = "Secrets Manager name for oauth2-proxy secrets"
  value       = aws_secretsmanager_secret.oauth2_proxy.name
}