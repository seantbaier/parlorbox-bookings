variable "name" {
  description = "The name of the API"
  type        = string
}

variable "description" {
  description = "The description of the API."
  type        = string
  default     = null
}

variable "protocol_type" {
  description = "The API protocol. Valid values: HTTP, WEBSOCKET"
  type        = string
  default     = "HTTP"
}

variable "cors_configuration" {
  description = "The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to API gateway resources."
  type        = map(string)
  default     = {}
}

variable "default_stage_access_log_destination_arn" {
  description = "Default stage's ARN of the CloudWatch Logs log group to receive access logs. Any trailing :* is trimmed from the ARN."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name to use for API gateway"
  type        = string
  default     = null
}

variable "domain_name_certificate_arn" {
  description = "The ARN of an AWS-managed certificate that will be used by the endpoint for the domain name"
  type        = string
  default     = null
}

variable "eventbridge_bus_name" {
  description = "Name of EventBus to send Put Events"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "eventbridge_bus_arn" {
  description = "EventBridge event bus ARN"
  type        = string
}
