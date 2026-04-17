resource "aws_service_discovery_http_namespace" "this" {
  name = "${var.project}-${var.env}"

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.env}-service-connect-namespace"
  })
}