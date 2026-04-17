resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-${var.env}-app"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-app-log-group"
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.env}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.app_image
      essential = true

      portMappings = [
        {
          name          = "app"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-app-task"
  })
}