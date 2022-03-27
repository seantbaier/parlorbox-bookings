locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  app_name       = local.account_vars.locals.app_name
  domain_name    = local.account_vars.locals.domain_name
  aws_account_id = local.account_vars.locals.aws_account_id
  environment    = local.environment_vars.locals.environment
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../modules//aws_event_bridge"
}


include {
  path = find_in_parent_folders()
}


dependency "events_firehose_stream" {
  config_path = "../../kinesis/events_firehose_stream"
}

dependency "eventbridge_log_group" {
  config_path = "../eventbridge_log_group"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  app_name         = local.app_name
  environment      = local.environment
  aws_account_id   = local.aws_account_id
  bus_name         = "${local.app_name}-event-bus-${local.environment}"
  role_name        = "${local.app_name}-event-bus-role-${local.environment}"
  role_description = "${local.environment} event Bus Role"


  rules = {
    "${local.app_name}-bookings-${local.environment}" = {
      description   = "Capture all booking events data"
      event_pattern = jsonencode({ "source" : ["connect.squareupsandbox.com"], "detail-type" : ["BOOKINGS"] })
      enabled       = true
    }
  }

  targets = {
    "${local.app_name}-bookings-${local.environment}" = [
      {
        name            = "send-bookings-to-firehose"
        arn             = dependency.events_firehose_stream.outputs.arn
        attach_role_arn = true
      },
      {
        name = "log-orders-to-cloudwatch"
        arn  = dependency.eventbridge_log_group.outputs.cloudwatch_log_group_arn
      }
    ]
  }

  attach_policy_json = true
  policy_json = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "firehose:PutRecord",
            "firehose:PutRecordBatch"
          ],
          "Resource" : [dependency.events_firehose_stream.outputs.arn]
        }
      ]
  })

  tags = {
    Name = "${local.app_name}-event-bus-${local.environment}"
  }
}
