locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  app_name       = local.account_vars.locals.app_name
  aws_account_id = local.account_vars.locals.aws_account_id
  domain_name    = local.account_vars.locals.domain_name
  environment    = local.environment_vars.locals.environment
  function_name  = "${local.app_name}-bookings-service-${local.environment}"
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/lambda/aws?2.34.1"
}

include {
  path = find_in_parent_folders()
}

dependency "docker_image" {
  config_path = "../../docker/image"
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  function_name = local.function_name

  create_package = false

  image_uri    = dependency.docker_image.outputs.image_uri
  package_type = "Image"

  role_name        = "${local.function_name}-role"
  trusted_entities = ["lambda.amazonaws.com"]

  #   allowed_triggers = {
  #     APIGatewayAny = {
  #       service    = "apigateway"
  #     #   source_arn = "arn:aws:execute-api:eu-west-1:135367859851:aqnku8akd0/*/*/*"
  #     },
  #     APIGatewayDevPost = {
  #       service    = "apigateway"
  #       source_arn = "arn:aws:execute-api:eu-west-1:135367859851:aqnku8akd0/dev/POST/*"
  #     },
  #     OneRule = {
  #       principal  = "events.amazonaws.com"
  #       source_arn = "arn:aws:events:eu-west-1:135367859851:rule/RunDaily"
  #     }
  #   }

  tags = {
    Name        = local.function_name
    Terraform   = "true"
    Environment = local.environment
  }
}
