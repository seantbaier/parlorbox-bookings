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
  source = "tfr:///terraform-aws-modules/eventbridge/aws//.?version=1.14.0"
}


include {
  path = find_in_parent_folders()
}


dependency "events_firehose_stream" {
  config_path = "../../kinesis/events_firehose_stream"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  bus_name  = "${local.app_name}-event-bus-${local.environment}"
  role_name = "${local.app_name}-event-bus-role-${local.environment}"

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
