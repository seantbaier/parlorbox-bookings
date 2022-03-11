resource "aws_route53_zone" "this" {
  name = var.name

  tags = {
    Name = var.name
  }
}
