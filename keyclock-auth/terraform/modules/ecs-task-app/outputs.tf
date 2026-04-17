output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "container_name" {
  value = "app"
}

output "container_port" {
  value = 8080
}