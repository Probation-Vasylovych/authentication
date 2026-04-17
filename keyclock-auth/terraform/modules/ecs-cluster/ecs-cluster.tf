resource "aws_ecs_cluster" "this" {
 name = "${var.project}-${var.env}-cluster"

  tags = merge(
    var.common_tags,
    {
      name = "${var.project}-${var.env}-cluster"
    }
  )
}