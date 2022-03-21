variable "environment" {
  description = "Environment resource is used in"
  type        = string
}

variable "app_name" {
  description = "App or project name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account Id"
  type        = string
}

variable "bus_name" {
  description = "A unique name for your EventBridge Bus"
  type        = string
  default     = "default"
}

variable "cloudwatch_target_arn" {
  description = "The Amazon Resource Name (ARN) of the Cloudwatch Log Streams you want to use as EventBridge targets"
  type        = string
}

variable "kinesis_firehose_target_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Firehose Delivery Stream you want to use as EventBridge target"
  type        = string
}


variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
}

variable "role_description" {
  description = "Description of IAM role to use for Lambda Function"
  type        = string
  default     = null
}
