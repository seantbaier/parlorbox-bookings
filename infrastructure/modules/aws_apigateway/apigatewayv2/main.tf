module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 0"

  name          = var.name
  description   = var.description
  protocol_type = var.protocol_type

  cors_configuration = var.cors_configuration

  # Custom domain
  domain_name                 = var.domain_name
  domain_name_certificate_arn = var.domain_name_certificate_arn

  default_stage_access_log_destination_arn = var.default_stage_access_log_destination_arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  integrations = {
    "POST /bookings" = {
      integration_type       = "AWS_PROXY"
      integration_subtype    = "EventBridge-PutEvents"
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
      credentials_arn        = module.apigateway_put_events_to_eventbridge_role.iam_role_arn


      request_parameters = {
        "Detail"       = "$request.body"
        "DetailType"   = "BOOKINGS"
        "Source"       = "connect.squareupsandbox.com"
        "EventBusName" = var.eventbridge_bus_name
        "Region"       = var.region
      }
    }
  }
}

module "apigateway_put_events_to_eventbridge_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.0"

  create_role = true

  role_name         = "apigateway-put-events-to-eventbridge"
  role_requires_mfa = false

  trusted_role_services = ["apigateway.amazonaws.com"]

  custom_role_policy_arns = [
    module.apigateway_put_events_to_eventbridge_policy.arn
  ]
}

module "apigateway_put_events_to_eventbridge_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.0"

  name        = "apigateway-put-events-to-eventbridge"
  description = "Allow PutEvents to EventBridge"

  policy = data.aws_iam_policy_document.apigateway_put_events_to_eventbridge_policy.json
}

data "aws_iam_policy_document" "apigateway_put_events_to_eventbridge_policy" {
  statement {
    sid       = "AllowPutEvents"
    actions   = ["events:PutEvents"]
    resources = [var.eventbridge_bus_arn]
  }
}
