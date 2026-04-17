output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "nginx_container_name" {
  value = "nginx"
}

output "nginx_container_port" {
  value = 8080
}