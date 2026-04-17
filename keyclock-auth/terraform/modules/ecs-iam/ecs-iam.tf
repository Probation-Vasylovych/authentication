resource "aws_iam_role" "task_execution" {
  name = "${var.project}-${var.env}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${var.project}-${var.env}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-ecs-task-role"
  })
}

data "aws_iam_policy_document" "secrets_access" {
  count = length(var.secrets_manager_secret_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = var.secrets_manager_secret_arns
  }
}

resource "aws_iam_policy" "secrets_access" {
  count = length(var.secrets_manager_secret_arns) > 0 ? 1 : 0

  name   = "${var.project}-${var.env}-ecs-secrets-access-policy"
  policy = data.aws_iam_policy_document.secrets_access[0].json

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-ecs-secrets-access-policy"
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  count = length(var.secrets_manager_secret_arns) > 0 ? 1 : 0

  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.secrets_access[0].arn
}