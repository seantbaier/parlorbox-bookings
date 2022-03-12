variable "name" {
  description = "Name of the data stream."
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 destination bucket ARN."
  type        = string
  default     = null
}

variable "lambda_arn" {
  description = "S3 destination bucket ARN."
  type        = string
  default     = null
}

variable "processing_configuration_enabled" {
  description = "(Optional) Enables or disables data processing."
  type        = string
  default     = null
}

variable "parameters" {
  description = "The parameters array objects"
  type        = list(map(any))
  default     = []
}

variable "firehose_role_name" {
  description = "Name of the Firehose Data Stream Role"
  type        = string
  default     = null
}

variable "error_output_prefix" {
  description = "(Optional) Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects."
  type        = string
  default     = null
}

variable "prefix" {
  description = "(Optional) The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
  default     = null
}
