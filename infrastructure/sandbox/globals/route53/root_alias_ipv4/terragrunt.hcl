
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  domain_name = local.account_vars.locals.domain_name
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../..//modules/aws_route53/record"
}

include {
  path = find_in_parent_folders()
}

dependency "hosted_zone" {
  config_path = "../hosted_zone"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name    = local.domain_name
  zone_id = dependency.hosted_zone.outputs.zone_id
  type    = "A"
  ttl     = 300
  values  = "127.0.0.1"
}
