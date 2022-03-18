locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  app_name    = local.account_vars.locals.app_name
  domain_name = local.account_vars.locals.domain_name
  account_id  = local.account_vars.locals.aws_account_id
  environment = local.environment_vars.locals.environment
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/eventbridge/aws//.?version=1.14.0"
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
  bus_name  = "${local.app_name}-event-bus-${local.environment}"
  role_name = "${local.app_name}-event-bus-role-${local.environment}"

  rules = {
    "${local.app_name}-bookings-${local.environment}" = {
      description   = "Capture all BOOKINGS events data"
      event_pattern = jsonencode({ "source" : ["connect.squareupsandbox.com"], "detail-type" : ["BOOKINGS"] })
      enabled       = true
    }
    "${local.app_name}-catchall-${local.environment}" = {
      description = "Capture all event data"
      event_pattern = jsonencode({
        "account" : [local.account_id]
      })
      enabled = true
    }
  }

  targets = {
    "${local.app_name}-bookings-${local.environment}" = [
      {
        name            = "send-bookings-to-firehose"
        arn             = dependency.events_firehose_stream.outputs.arn
        attach_role_arn = true
      }
    ]

    "${local.app_name}-catchall-${local.environment}" = [
      {
        name = "log-events-to-cloudwatch"
        arn  = dependency.eventbridge_log_group.outputs.cloudwatch_log_group_arn
      }
    ]
  }

  create_archives = true
  archives = {
    "${local.app_name}-archive-${local.environment}" = {
      description    = "Booking Event archive",
      retention_days = 30
      event_pattern  = <<PATTERN
      {
        "source": ["connect.squareupsandbox.com"],
        "detail-type": ["BOOKINGS"]
      }
      PATTERN
    }
  }

  tags = {
    Name = "${local.app_name}-event-bus-${local.environment}"
  }
}
