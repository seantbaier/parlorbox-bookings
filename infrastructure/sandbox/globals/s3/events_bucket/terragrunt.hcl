locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  app_name     = local.account_vars.locals.app_name
  account_name = local.account_vars.locals.account_name
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=2.14.1"
}

include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  #   environment             = local.account_name
  bucket = "${local.account_name}-${local.app_name}-events"
  acl    = "private"

  versioning = {
    enabled = false
  }
}
