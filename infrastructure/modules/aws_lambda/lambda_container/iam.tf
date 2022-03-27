locals {
  create_role = var.create && var.create_role
}

###########
# IAM role
###########

data "aws_iam_policy_document" "assume_role" {
  count = local.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = distinct(concat(["lambda.amazonaws.com"], var.trusted_entities))
    }
  }
}

resource "aws_iam_role" "lambda" {
  count = local.create_role ? 1 : 0

  name                  = "${var.function_name}-role"
  description           = var.role_description
  path                  = var.role_path
  force_detach_policies = var.role_force_detach_policies
  permissions_boundary  = var.role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  managed_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]


  tags = merge(var.tags, var.role_tags)
}

###########################
# Additional policy (JSON)
###########################

resource "aws_iam_policy" "additional_json" {
  count = local.create_role && var.attach_policy_json ? 1 : 0

  name   = local.role_name
  policy = var.policy_json
}

resource "aws_iam_policy_attachment" "additional_json" {
  count = local.create_role && var.attach_policy_json ? 1 : 0

  name       = local.role_name
  roles      = [aws_iam_role.lambda[0].name]
  policy_arn = aws_iam_policy.additional_json[0].arn
}
