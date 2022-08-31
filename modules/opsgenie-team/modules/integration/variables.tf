variable "team_name" {
  type        = string
  description = "Name of the team to assign this integration to."
}

variable "ssm_path_format" {
  type        = string
  default     = "/opsgenie-team/%s"
  description = "SSM parameter name format"
}

variable "kms_key_arn" {
  type        = string
  default     = "alias/aws/ssm"
  description = "AWS KMS key used for writing to SSM"
}

variable "type" {
  type        = string
  description = "API Integration Type"
}

variable "append_datadog_tags_enabled" {
  type        = bool
  default     = true
  description = "Add Datadog Tags to the Tags of alerts from this integration."
}
