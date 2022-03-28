locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  app_name     = local.account_vars.locals.app_name
  account_name = local.account_vars.locals.account_name
  environment  = local.environment_vars.locals.environment
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../..//modules/aws_dynamodb/dynamodb_table"
}

include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name             = "Merchant-${local.app_name}-${local.environment}"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  hash_key         = "PK"
  range_key        = "SK"

  attributes = [
    {
      name = "PK"
      type = "S"
    },
    {
      name = "SK"
      type = "S"
    },
    {
      name = "GSI1PK"
      type = "S"
    },
  ]

  global_secondary_indexes = [{
    name            = "GSI1-MerchantEmail"
    hash_key        = "GSI1PK"
    projection_type = "ALL"
  }]

  tags = {
    Terraform   = true
    Environment = local.environment
  }
}
