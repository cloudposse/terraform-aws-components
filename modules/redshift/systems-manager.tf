# AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "ssm_enabled" {
  type        = bool
  default     = false
  description = "If `true` create SSM keys for the database user and password."
}

variable "ssm_key_format" {
  type        = string
  default     = "/%v/%v/%v"
  description = "SSM path format. The values will will be used in the following order: `var.ssm_key_prefix`, `var.name`, `var.ssm_key_*`"
}

variable "ssm_key_prefix" {
  type        = string
  default     = "redshift"
  description = "SSM path prefix. Omit the leading forward slash `/`."
}

variable "ssm_key_user" {
  type        = string
  default     = "admin/db_user"
  description = "The SSM key to save the user. See `var.ssm_path_format`."
}

variable "ssm_key_password" {
  type        = string
  default     = "admin/db_password"
  description = "The SSM key to save the password. See `var.ssm_path_format`."
}

variable "ssm_key_hostname" {
  type        = string
  default     = "admin/db_hostname"
  description = "The SSM key to save the hostname. See `var.ssm_path_format`."
}

variable "ssm_key_port" {
  type        = string
  default     = "admin/db_port"
  description = "The SSM key to save the port. See `var.ssm_path_format`."
}

locals {
  ssm_enabled = local.enabled && var.ssm_enabled
}

resource "aws_ssm_parameter" "redshift_database_name" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, var.name, var.ssm_key_port)
  value       = local.database_name
  description = "Redshift DB port"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "redshift_database_user" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, var.name, var.ssm_key_user)
  value       = local.admin_user
  description = "Redshift DB user"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "redshift_database_password" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, var.name, var.ssm_key_password)
  value       = local.admin_password
  description = "Redshift DB password"
  type        = "SecureString"
  key_id      = var.kms_alias_name_ssm
  overwrite   = true
}

resource "aws_ssm_parameter" "redshift_database_hostname" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, var.name, var.ssm_key_hostname)
  value       = module.redshift_cluster.endpoint
  description = "Redshift DB hostname"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "redshift_database_port" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, var.name, var.ssm_key_port)
  value       = var.port
  description = "Redshift DB port"
  type        = "String"
  overwrite   = true
}

output "redshift_database_ssm_key_prefix" {
  value       = local.ssm_enabled ? format(var.ssm_key_format, var.ssm_key_prefix, var.name, "") : null
  description = "SSM prefix"
}
