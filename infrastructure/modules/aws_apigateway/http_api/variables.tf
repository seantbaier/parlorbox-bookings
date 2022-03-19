variable "create" {
  description = "Create resource conditionally."
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "AWS resrouce tags."
  type        = map(any)
  default     = {}
}

variable "name" {
  description = "Name for the API Gateway Stage."
  type        = string
}

variable "stage_name" {
  description = "Name for the AWS resource."
  type        = string
}

variable "protocol_type" {
  description = "(Required) The API protocol. Valid values: HTTP, WEBSOCKET."
  type        = string
}

variable "payload_format_version" {
  description = "(Optional) The format of the payload sent to an integration. Valid values: 1.0, 2.0. Default is 1.0."
  type        = string
  default     = "1.0"
}

variable "domain_name" {
  description = "(Required) The domain name. Must be between 1 and 512 characters in length."
  type        = string
}

variable "domain_name_certificate_arn" {
  description = "(Required) The ARN of an AWS-managed certificate that will be used by the endpoint for the domain name. AWS Certificate Manager is the only supported source. Use the aws_acm_certificate resource to configure an ACM certificate."
  type        = string
}

variable "eventbridge_bus_arn" {
  description = "EventBridge event bus ARN"
  type        = string
}

variable "eventbridge_bus_name" {
  description = "EventBridge event bus name"
  type        = string
}

variable "cors_configuration" {
  description = "The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs."
  type        = any
  default     = {}
}

variable "route_selection_expression" {
  description = "Route selection expression"
  type        = string
  default     = null
}

variable "api_version" {
  description = "A version identifier for the API"
  type        = string
  default     = null
}

variable "description" {
  description = "The description of the API."
  type        = string
  default     = null
}

variable "stage_access_log_destination_arn" {
  description = "Default stage's ARN of the CloudWatch Logs log group to receive access logs. Any trailing :* is trimmed from the ARN."
  type        = string
  default     = null
}


variable "stage_access_log_format" {
  description = "Stage logs format"
  type        = string
  default     = null
}


variable "hosted_zone_id" {
  description = "Route53 Hosted Zone Id"
  type        = string
}
