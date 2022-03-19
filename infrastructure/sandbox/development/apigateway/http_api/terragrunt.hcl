locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  app_name    = local.account_vars.locals.app_name
  domain_name = local.account_vars.locals.domain_name
  environment = local.environment_vars.locals.environment
  region      = local.region_vars.locals.aws_region
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../..//modules/aws_apigateway/http_api"
}


include {
  path = find_in_parent_folders()
}


dependency "certificate" {
  config_path = "../../../globals/acm/certificate"
}

dependency "apigateway_log_group" {
  config_path = "../../cloudwatch/apigateway_log_group"
}


dependency "event_bus" {
  config_path = "../../event_bridge/event_bus"
}

dependency "hosted_zone" {
  config_path = "../../../globals/route53/hosted_zone"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name          = "${local.app_name}-api-${local.environment}"
  stage_name    = local.environment
  description   = "HTTP API Gateway for Square Webhooks"
  protocol_type = "HTTP"
  region        = local.region

  cors_configuration = {
    # TODO Lock this down to only accept  requests from Sqaure Webhooks API connect.squareupsandbox.com
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  hosted_zone_id              = dependency.hosted_zone.outputs.zone_id
  domain_name                 = "${local.environment}.${local.domain_name}"
  domain_name_certificate_arn = dependency.certificate.outputs.acm_certificate_arn

  # Access logs
  stage_access_log_destination_arn = dependency.apigateway_log_group.outputs.cloudwatch_log_group_arn
  stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  eventbridge_bus_name = dependency.event_bus.outputs.eventbridge_bus_name
  eventbridge_bus_arn  = dependency.event_bus.outputs.eventbridge_bus_arn


  tags = {
    Environment = local.environment
  }
}
