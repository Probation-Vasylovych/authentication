output "task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.task.arn
}

output "task_execution_role_name" {
  description = "ECS task execution role name"
  value       = aws_iam_role.task_execution.name
}