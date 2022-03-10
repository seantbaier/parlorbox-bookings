
# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "sandbox"
  app_name       = "proper"
  domain_name    = "deadbear.io"
  aws_account_id = "616285773385"
  aws_profile    = "terraform"
}
