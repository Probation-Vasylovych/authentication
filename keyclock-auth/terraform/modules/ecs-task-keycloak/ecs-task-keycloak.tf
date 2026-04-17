resource "aws_cloudwatch_log_group" "keycloak" {
  name              = "/ecs/${var.project}-${var.env}-keycloak"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-keycloak-log-group"
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.env}-keycloak"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "1024"
  memory = "2048"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "keycloak"
      image     = var.keycloak_image
      essential = true

      portMappings = [
        {
          name          = "keycloak"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      command = [
        "start-dev"
      ]

      environment = [
        {
          name  = "KC_BOOTSTRAP_ADMIN_USERNAME"
          value = var.keycloak_admin_username
        },
        {
          name  = "KC_BOOTSTRAP_ADMIN_PASSWORD"
          value = var.keycloak_admin_password
        },
        {
          name  = "KC_HTTP_ENABLED"
          value = "true"
        },
        {
          name  = "KC_PROXY_HEADERS"
          value = "xforwarded"
        },
        {
          name  = "KC_HOSTNAME"
          value = "https://keycloak.${var.domain_name}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.keycloak.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "keycloak"
        }
      }
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-keycloak-task"
  })
}