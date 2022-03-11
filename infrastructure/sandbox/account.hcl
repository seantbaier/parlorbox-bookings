
# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "sandbox"
  app_name       = "parlorbox"
  domain_name    = "parlorbox.com"
  aws_account_id = "616285773385"
  aws_profile    = "terraform"
}
