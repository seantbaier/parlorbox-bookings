locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  app_name       = local.account_vars.locals.app_name
  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
  environment    = local.environment_vars.locals.environment
}

terraform {
  source = "../../../..//modules/aws_kinesis_firehose"
}


include {
  path = find_in_parent_folders()
}

dependency "bookings_service" {
  config_path = "../../lambda/bookings_service"
}

dependency "events_bucket" {
  config_path = "../../s3/events_bucket"
}

inputs = {
  name           = "${local.app_name}-bookings-stream-${local.environment}"
  s3_bucket_arn  = dependency.events_bucket.outputs.s3_bucket_arn
  s3_bucket_name = dependency.events_bucket.outputs.s3_bucket_id
  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region

  processing_configuration_enabled = "true"
  processors_type                  = "Lambda"
  prefix                           = "bookings/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  error_output_prefix              = "errors/bookings/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  lambda_arn                       = dependency.bookings_service.outputs.arn

  parameters = [{
    parameter_name  = "LambdaArn"
    parameter_value = dependency.bookings_service.outputs.arn
  }]

  firehose_role_name = "${local.app_name}-firehose-role-${local.environment}"
}
