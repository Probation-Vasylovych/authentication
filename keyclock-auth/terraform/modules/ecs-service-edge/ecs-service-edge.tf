resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.env}-edge"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn

  launch_type   = "FARGATE"
  desired_count = 1

  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_connect_namespace_arn
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-edge-service"
  })
}