resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.env}-alb-sg"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic from ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-alb-sg"
  })
}

resource "aws_security_group" "edge_service" {
  name        = "${var.project}-${var.env}-edge-service-sg"
  description = "Security group for ECS edge service: nginx + oauth2-proxy"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ALB to reach nginx"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic from edge service"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-edge-service-sg"
  })
}

resource "aws_security_group" "keycloak_service" {
  name        = "${var.project}-${var.env}-keycloak-service-sg"
  description = "Security group for ECS Keycloak service"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ALB to reach Keycloak"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Allow edge service to reach Keycloak"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.edge_service.id]
  }

  egress {
    description = "Allow outbound traffic from Keycloak service"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-keycloak-service-sg"
  })
}

resource "aws_security_group" "app_service" {
  name        = "${var.project}-${var.env}-app-service-sg"
  description = "Security group for ECS application service"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow edge service to reach app"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.edge_service.id]
  }

  egress {
    description = "Allow outbound traffic from app service"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-app-service-sg"
  })
}