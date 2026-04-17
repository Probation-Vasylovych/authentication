resource "aws_cloudwatch_log_group" "edge" {
  name              = "/ecs/${var.project}-${var.env}-edge"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-edge-log-group"
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.env}-edge"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "512"
  memory = "1024"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = var.nginx_image
      essential = true

      portMappings = [
        {
          name          = "nginx"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      dependsOn = [
        {
          containerName = "oauth2-proxy"
          condition     = "START"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.edge.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "nginx"
        }
      }
    },
    {
      name      = "oauth2-proxy"
      image     = var.oauth2_proxy_image
      essential = true

      portMappings = [
        {
          name          = "oauth2-proxy"
          containerPort = 4180
          hostPort      = 4180
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      environment = [
        {
          name  = "OAUTH2_PROXY_PROVIDER"
          value = "keycloak-oidc"
        },
        {
          name  = "OAUTH2_PROXY_OIDC_ISSUER_URL"
          value = "https://keycloak.${var.domain_name}/realms/${var.keycloak_realm}"
        },
        {
          name  = "OAUTH2_PROXY_CLIENT_ID"
          value = var.oauth2_proxy_client_id
        },
        {
          name  = "OAUTH2_PROXY_REDIRECT_URL"
          value = "https://${var.domain_name}/oauth2/callback"
        },
        {
          name  = "OAUTH2_PROXY_EMAIL_DOMAINS"
          value = "*"
        },
        {
          name  = "OAUTH2_PROXY_COOKIE_SECURE"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_COOKIE_HTTPONLY"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_COOKIE_SAMESITE"
          value = "lax"
        },
        {
          name  = "OAUTH2_PROXY_HTTP_ADDRESS"
          value = "0.0.0.0:4180"
        },
        {
          name  = "OAUTH2_PROXY_REVERSE_PROXY"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_SET_XAUTHREQUEST"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_PASS_ACCESS_TOKEN"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_PASS_AUTHORIZATION_HEADER"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_PASS_USER_HEADERS"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_SKIP_PROVIDER_BUTTON"
          value = "true"
        },
        {
          name  = "OAUTH2_PROXY_CODE_CHALLENGE_METHOD"
          value = "S256"
        },
        {
          name  = "OAUTH2_PROXY_WHITELIST_DOMAINS"
          value = "birdswatching.pp.ua"
        },
        {
          name  = "OAUTH2_PROXY_SSL_INSECURE_SKIP_VERIFY"
          value = "false"
        }
      ]

      secrets = [
        {
          name      = "OAUTH2_PROXY_CLIENT_SECRET"
          valueFrom = "${var.oauth2_proxy_secret_arn}:client_secret::"
        },
        {
          name      = "OAUTH2_PROXY_COOKIE_SECRET"
          valueFrom = "${var.oauth2_proxy_secret_arn}:cookie_secret::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.edge.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "oauth2-proxy"
        }
      }
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-edge-task"
  })
}