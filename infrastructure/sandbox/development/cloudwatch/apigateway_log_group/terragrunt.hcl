
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  app_name    = local.account_vars.locals.app_name
  environment = local.environment_vars.locals.environment
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/cloudwatch/aws//modules/log-group?version=2.4.1"
}


include {
  path = find_in_parent_folders()
}




inputs = {
  name              = "${local.app_name}-apigateway-logs-${local.environment}"
  retention_in_days = 120


}
