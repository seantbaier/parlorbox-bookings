resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
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
  }

}


resource "aws_iam_role" "firehose_role" {
  name = var.firehose_role_name

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

