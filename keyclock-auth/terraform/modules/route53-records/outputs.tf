output "root_record_fqdn" {
  description = "Root domain Route 53 record FQDN"
  value       = aws_route53_record.root.fqdn
}

output "keycloak_record_fqdn" {
  description = "Keycloak Route 53 record FQDN"
  value       = aws_route53_record.keycloak.fqdn
}