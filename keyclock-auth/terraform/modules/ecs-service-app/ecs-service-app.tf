resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.env}-app"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn

  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_connect_namespace_arn

    service {
      port_name      = "app"
      discovery_name = "app"

      client_alias {
        dns_name = "app"
        port     = 8080
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-app-service"
  })
}