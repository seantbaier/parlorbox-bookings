locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  domain_name = local.account_vars.locals.domain_name
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../..//modules/aws_route53/hosted_zone"
}

include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = local.domain_name
}
