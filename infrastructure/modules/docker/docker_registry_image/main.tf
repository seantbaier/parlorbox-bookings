data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

locals {
  image_tag          = "latest"
  repository_address = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}


provider "docker" {
  registry_auth {
    address  = local.repository_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "this" {
  name = "${local.repository_address}/${var.name}:${local.image_tag}"

  build {
    context    = "../context"
    dockerfile = "Dockerfile"
  }
}
