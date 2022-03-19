locals {
  base_tags = {
    Terraform = true
  }

  tags = merge(local.base_tags, var.tags)
}

resource "aws_apigatewayv2_api" "this" {
  count = var.create ? 1 : 0

  name          = var.name
  description   = var.description
  protocol_type = var.protocol_type
  version       = var.api_version

  dynamic "cors_configuration" {
    for_each = length(keys(var.cors_configuration)) == 0 ? [] : [var.cors_configuration]

    content {
      allow_credentials = lookup(cors_configuration.value, "allow_credentials", null)
      allow_headers     = lookup(cors_configuration.value, "allow_headers", null)
      allow_methods     = lookup(cors_configuration.value, "allow_methods", null)
      allow_origins     = lookup(cors_configuration.value, "allow_origins", null)
      expose_headers    = lookup(cors_configuration.value, "expose_headers", null)
      max_age           = lookup(cors_configuration.value, "max_age", null)
    }
  }

  tags = local.tags
}


resource "aws_apigatewayv2_integration" "bookings" {

  api_id      = aws_apigatewayv2_api.this[0].id
  description = null

  integration_type    = "AWS_PROXY"
  integration_subtype = "EventBridge-PutEvents"
  integration_uri     = null


  payload_format_version = "1.0"
  timeout_milliseconds   = 12000
  credentials_arn        = aws_iam_role.this.arn

  request_parameters = {
    "Detail"       = "$request.body"
    "DetailType"   = "BOOKINGS"
    "Source"       = "connect.squareupsandbox.com"
    "EventBusName" = var.eventbridge_bus_name
    "Region"       = var.region
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_apigatewayv2_route" "bookings" {
  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = "POST /bookings"

  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.bookings.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  count = var.create ? 1 : 0

  api_id = aws_apigatewayv2_api.this[0].id
  name   = "$default"

  access_log_settings {
    destination_arn = var.stage_access_log_destination_arn
    format          = var.stage_access_log_format
  }

  auto_deploy = true

  tags = local.tags
}

resource "aws_apigatewayv2_domain_name" "this" {
  count = var.create ? 1 : 0

  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.domain_name_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.create ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.this[0].id
  stage       = aws_apigatewayv2_stage.this[0].id
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = []
    }

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "this" {
  name               = "apigateway-put-events-to-eventbridge"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "this" {
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

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


resource "aws_route53_record" "ipv4" {
  name    = aws_apigatewayv2_domain_name.this[0].domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name    = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name
    zone_id = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id

    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ipv6" {
  name    = aws_apigatewayv2_domain_name.this[0].domain_name
  type    = "AAAA"
  zone_id = var.hosted_zone_id

  alias {
    name    = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name
    zone_id = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id

    evaluate_target_health = false
  }
}
