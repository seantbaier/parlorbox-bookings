locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  app_name    = local.account_vars.locals.app_name
  environment = local.environment_vars.locals.environment
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../..//modules/docker/docker_registry_image"
}

include {
  path = find_in_parent_folders()
}

dependency "ecr_repository" {
  config_path = "../../ecr/repository"
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name               = "${local.app_name}-bookings-service-${local.environment}"
  environment        = local.environment
  repository_address = dependency.ecr_repository.outputs.repository_url
}
