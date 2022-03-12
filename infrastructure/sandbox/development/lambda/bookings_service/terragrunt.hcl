locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  app_name      = local.account_vars.locals.app_name
  environment   = local.environment_vars.locals.environment
  function_name = "${local.app_name}-bookings-service-${local.environment}"
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../..//modules/aws_lambda/lambda_container"
}

include {
  path = find_in_parent_folders()
}

dependency "docker_image" {
  config_path = "../../docker/image"
}

inputs = {
  function_name = local.function_name
  environment   = local.environment

  create_package = false

  image_uri    = dependency.docker_image.outputs.image_uri
  package_type = "Image"

  role_name        = "${local.function_name}-role-${local.environment}"
  trusted_entities = ["lambda.amazonaws.com"]

  environment_variables = {
    LOG_LEVEL = "debug"
  }

  tags = {
    Name        = local.function_name
    Terraform   = "true"
    Environment = local.environment
  }
}
