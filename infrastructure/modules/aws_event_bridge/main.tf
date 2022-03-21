resource "aws_cloudwatch_event_bus" "event_bus" {
  name = var.bus_name
}


resource "aws_cloudwatch_event_rule" "kinesis_firehose_rule" {
  name = "${var.app_name}-bookings-${var.environment}"

  event_bus_name = aws_cloudwatch_event_bus.event_bus.name

  description = "Capture all BOOKINGS events data"
  is_enabled  = true
  event_pattern = jsonencode({
    "source" : ["connect.squareupsandbox.com"], "detail-type" : ["BOOKINGS"]
  })
  role_arn = aws_iam_role.eventbridge.arn
}

resource "aws_cloudwatch_event_rule" "catchall_rule" {
  name = "${var.app_name}-catchall-${var.environment}"

  event_bus_name = aws_cloudwatch_event_bus.event_bus.name

  description = "Capture all event data"
  is_enabled  = true
  event_pattern = jsonencode({
    "account" : [var.aws_account_id]
  })
  role_arn = aws_iam_role.eventbridge.arn
}

resource "aws_cloudwatch_event_target" "kinesis_firehose_target" {
  event_bus_name = var.bus_name

  rule      = aws_cloudwatch_event_rule.kinesis_firehose_rule.name
  arn       = var.kinesis_firehose_target_arn
  role_arn  = aws_iam_role.eventbridge.arn
  target_id = "send-bookings-to-firehose"

  depends_on = [aws_cloudwatch_event_rule.kinesis_firehose_rule]
}

resource "aws_cloudwatch_event_target" "catchall_cloudwatch_target" {
  event_bus_name = var.bus_name

  rule      = aws_cloudwatch_event_rule.catchall_rule.name
  arn       = var.cloudwatch_target_arn
  target_id = "log-events-to-cloudwatch"

  depends_on = [aws_cloudwatch_event_rule.catchall_rule]
}

# resource "aws_cloudwatch_event_permission" "this" {
#   principal    = ["events.amazonaws.com", "delivery.logs.amazonaws.com"]
#   statement_id = ["TrustEventsToStoreLogEvent"]

#   action = [
#     "logs:CreateLogStream",
#     "logs:PutLogEvents"
#   ]
#   event_bus_name = aws_cloudwatch_event_bus.event_bus.name
# }


##########################
# Iam Config
##########################


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge" {
  name        = var.role_name
  description = var.role_description
  #   path                  = var.role_path
  #   force_detach_policies = var.role_force_detach_policies
  #   permissions_boundary  = var.role_permissions_boundary
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



##################
# Kinesis Config
##################

# data "aws_iam_policy_document" "kinesis" {
#   statement {
#     sid       = "KinesisAccess"
#     effect    = "Allow"
#     actions   = ["kinesis:PutRecord"]
#     resources = var.kinesis_target_arns
#   }
# }

# resource "aws_iam_policy" "kinesis" {
#   name   = "${local.role_name}-kinesis"
#   policy = data.aws_iam_policy_document.kinesis.json
# }

# resource "aws_iam_policy_attachment" "kinesis" {
#   name       = "${local.role_name}-kinesis"
#   roles      = [aws_iam_role.eventbridge.name]
#   policy_arn = aws_iam_policy.kinesis.arn
# }

##########################
# Kinesis Firehose Config
##########################

data "aws_iam_policy_document" "kinesis_firehose" {
  statement {
    sid       = "KinesisFirehoseAccess"
    effect    = "Allow"
    actions   = ["firehose:PutRecord"]
    resources = [var.kinesis_firehose_target_arn]
  }
}

resource "aws_iam_policy" "kinesis_firehose" {
  name   = "${var.role_name}-kinesis-firehose"
  policy = data.aws_iam_policy_document.kinesis_firehose.json
}

resource "aws_iam_policy_attachment" "kinesis_firehose" {
  name       = "${var.role_name}-kinesis-firehose"
  roles      = [aws_iam_role.eventbridge.name]
  policy_arn = aws_iam_policy.kinesis_firehose.arn
}



##########################
# Cloudwatch Config
##########################

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid    = "CloudwatchAccess"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [var.cloudwatch_target_arn]
  }
}

resource "aws_iam_policy" "cloudwatch" {
  name   = "${var.role_name}-cloudwatch"
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       = "${var.role_name}-cloudwatch"
  roles      = [aws_iam_role.eventbridge.name]
  policy_arn = aws_iam_policy.cloudwatch.arn
}
