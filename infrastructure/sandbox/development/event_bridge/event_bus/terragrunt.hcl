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

  kinesis_firehose_target_arn = dependency.events_firehose_stream.outputs.arn
  cloudwatch_target_arn       = dependency.eventbridge_log_group.outputs.cloudwatch_log_group_arn



  #     "${local.app_name}-catchall-${local.environment}" = [
  #       {
  #         name = "log-events-to-cloudwatch"
  #         arn  = dependency.eventbridge_log_group.outputs.cloudwatch_log_group_arn
  #       }
  #     ]
  #   }

  #   create_archives = true
  #   archives = {
  #     "${local.app_name}-archive-${local.environment}" = {
  #       description    = "Booking Event archive",
  #       retention_days = 30
  #       event_pattern  = <<PATTERN
  #       {
  #         "source": ["connect.squareupsandbox.com"],
  #         "detail-type": ["BOOKINGS"]
  #       }
  #       PATTERN
  #     }
  #   }

  tags = {
    Name = "${local.app_name}-event-bus-${local.environment}"
  }
}
