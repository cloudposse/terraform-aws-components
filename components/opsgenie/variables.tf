variable "region" {
  type        = string
  description = "AWS Region"
}

variable "kms_key_arn" {
  type        = string
  default     = "alias/aws/ssm"
  description = "AWS KMS key used for writing to SSM"
}

variable "ssm_parameter_name_format" {
  type        = string
  default     = "/%s/%s"
  description = "SSM parameter name format"
}

variable "ssm_path" {
  type        = string
  default     = "opsgenie"
  description = "SSM path"
}
