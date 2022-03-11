resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  tags = {
    App         = var.name
    Terraform   = true
    Environment = var.environment
  }
}
