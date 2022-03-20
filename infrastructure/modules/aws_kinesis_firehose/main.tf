resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.this.arn
    bucket_arn          = var.s3_bucket_arn
    prefix              = var.prefix
    error_output_prefix = var.error_output_prefix

    processing_configuration {
      enabled = var.processing_configuration_enabled

      processors {
        type = "Lambda"

        dynamic "parameters" {
          for_each = var.parameters

          content {
            parameter_name  = parameters.value.parameter_name
            parameter_value = parameters.value.parameter_value
          }

        }
      }
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "this" {
  name               = var.firehose_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



data "aws_iam_policy_document" "firehose" {

  statement {
    effect = "Allow"

    # actions = [
    #   "s3:AbortMultipartUpload",
    #   "s3:GetBucketLocation",
    #   "s3:GetObject",
    #   "s3:ListBucket",
    #   "s3:ListBucketMultipartUploads",
    #   "s3:PutObject"
    # ]

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:kms:us-east-1:616285773385:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]


    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "s3.us-east-1.amazonaws.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*",
        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.arn}:log-stream:*",
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%:log-stream:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = ["arn:aws:kinesis:${var.aws_region}:${var.aws_account_id}:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:kms:us-east-1:616285773385:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["kinesis.us-east-1.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"

      values = ["arn:aws:kinesis:${var.aws_region}:${var.aws_account_id}:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"]
    }

  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]

    resources = [var.lambda_arn]
  }
}



resource "aws_iam_policy" "firehose" {
  name   = "${var.firehose_role_name}-policy"
  policy = data.aws_iam_policy_document.firehose.json
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.firehose.arn
}



# data "aws_iam_policy_document" "firehose_put_events_lambda" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "lambda:InvokeFunction",
#       "lambda:GetFunctionConfiguration"
#     ]

#     resources = [var.lambda_arn]
#   }
# }



# resource "aws_iam_policy" "firehose_put_events_lambda" {
#   name   = "${var.firehose_role_name}-put-event-lambda"
#   policy = data.aws_iam_policy_document.firehose_put_events_lambda.json
# }

# resource "aws_iam_role_policy_attachment" "firehose_put_events_lambda" {
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_policy.firehose_put_events_lambda.arn
# }



# data "aws_iam_policy_document" "firehose_s3" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "s3:AbortMultipartUpload",
#       "s3:GetBucketLocation",
#       "s3:GetObject",
#       "s3:ListBucket",
#       "s3:ListBucketMultipartUploads",
#       "s3:PutObject"
#     ]

#     resources = [
#       "arn:aws:s3:::${var.s3_bucket_name}",
#       "arn:aws:s3:::${var.s3_bucket_name}/*"
#     ]
#   }
# }


# resource "aws_iam_policy" "firehose_s3" {
#   name   = "${var.firehose_role_name}-s3"
#   policy = data.aws_iam_policy_document.firehose_s3.json
# }

# resource "aws_iam_role_policy_attachment" "firehose_s3" {
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_policy.firehose_s3.arn
# }



resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "S3Delivery"
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name              = "/aws/kinesisfirehose/${var.name}"
  retention_in_days = 120
}


resource "aws_iam_policy" "firehose_logging" {
  name        = "${var.name}-logging-policy"
  path        = "/"
  description = "IAM policy for logging from a firehose"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_logs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.firehose_logging.arn
}

