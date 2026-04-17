resource "random_password" "cookie_secret" {
  length           = 32
  override_special = "-_"
}

resource "aws_secretsmanager_secret" "oauth2_proxy" {
  name = "${var.project}/${var.env}/oauth2-proxy"

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-oauth2-proxy-secret"
  })
}

resource "aws_secretsmanager_secret_version" "oauth2_proxy" {
  secret_id = aws_secretsmanager_secret.oauth2_proxy.id

  secret_string = jsonencode({
    client_secret = var.oauth2_proxy_client_secret
    cookie_secret = random_password.cookie_secret.result
  })
}