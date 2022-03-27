variable "create" {
  description = "Controls whether resources should be created"
  type        = bool
  default     = true
}

variable "create_role" {
  description = "Controls whether IAM roles should be created"
  type        = bool
  default     = true
}

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

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

######
# IAM
######

variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_description" {
  description = "Description of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the IAM role has before destroying it."
  type        = bool
  default     = true
}

variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role used by Lambda Function"
  type        = string
  default     = null
}

variable "role_tags" {
  description = "A map of tags to assign to IAM role"
  type        = map(string)
  default     = {}
}


variable "policy_json" {
  description = "An additional policy document as JSON to attach to IAM role"
  type        = string
  default     = null
}

variable "attach_policy_json" {
  description = "Controls whether policy_json should be added to IAM role"
  type        = bool
  default     = false
}
