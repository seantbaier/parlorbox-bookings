locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  app_name    = local.account_vars.locals.app_name
  domain_name = local.account_vars.locals.domain_name
  environment = local.environment_vars.locals.environment
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/apigateway-v2/aws//.?version=1.5.1"
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

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name          = "${local.app_name}-api-${local.environment}"
  description   = "HTTP API Gateway for Square Webhooks"
  protocol_type = "HTTP"

  cors_configuration = {
    # TODO Lock this down to only accept  requests from Sqaure Webhooks API connect.squareupsandbox.com
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  domain_name                 = local.domain_name
  domain_name_certificate_arn = dependency.certificate.outputs.acm_certificate_arn

  # Access logs
  default_stage_access_log_destination_arn = dependency.apigateway_log_group.outputs.cloudwatch_log_group_arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "POST /" = {
      lambda_arn             = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = "arn:aws:lambda:eu-west-1:052235179155:function:my-default-function"
    }
  }
  tags = {
    Name = "http-apigateway"
  }
}
