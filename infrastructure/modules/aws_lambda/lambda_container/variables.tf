variable "environment" {
  description = "Name of the environment the resources are being deployed to."
  type        = string
  default     = "dev"
}

variable "function_name" {
  description = "Name of function"
  type        = string
}

variable "image_uri" {
  description = "The ECR image URI for deploying lambda"
  type        = string
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "trusted_entities" {
  description = "List of additional trusted entities for assuming Lambda Function role (trust relationship)"
  type        = any
  default     = []
}

variable "architectures" {
  description = "(Optional) Instruction set architecture for your Lambda function. Valid values are ['x86_64'] and ['arm64']. Default is ['x86_64']. Removing this attribute, function's architecture stay the same."
  type        = any
  default     = null
}

variable "package_type" {
  description = "(Optional) Lambda deployment package type. Valid values are Zip and Image. Defaults to Zip."
  type        = string
}

variable "entry_point" {
  description = "(Optional) Entry point to your application, which is typically the location of the runtime executable."
  type        = list(string)
  default     = null
}
