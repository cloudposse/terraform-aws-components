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
  default     = "rds"
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
  ssm_enabled                = local.enabled && var.ssm_enabled
  ssm_name_path              = join("-", compact(concat([var.name], var.attributes)))
  rds_database_password_path = format(var.ssm_key_format, var.ssm_key_prefix, local.ssm_name_path, var.ssm_key_password)
}

resource "aws_ssm_parameter" "rds_database_user" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, local.ssm_name_path, var.ssm_key_user)
  value       = local.database_user
  description = "RDS DB user"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "rds_database_password" {
  count = local.ssm_enabled ? 1 : 0

  name        = local.rds_database_password_path
  value       = local.database_password
  description = "RDS DB password"
  type        = "SecureString"
  key_id      = var.kms_alias_name_ssm
  overwrite   = true
}

resource "aws_ssm_parameter" "rds_database_hostname" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, local.ssm_name_path, var.ssm_key_hostname)
  value       = module.rds_instance.hostname == "" ? module.rds_instance.instance_address : module.rds_instance.hostname
  description = "RDS DB hostname"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "rds_database_port" {
  count = local.ssm_enabled ? 1 : 0

  name        = format(var.ssm_key_format, var.ssm_key_prefix, local.ssm_name_path, var.ssm_key_port)
  value       = var.database_port
  description = "RDS DB port"
  type        = "String"
  overwrite   = true
}

output "rds_database_ssm_key_prefix" {
  value       = local.ssm_enabled ? format(var.ssm_key_format, var.ssm_key_prefix, local.ssm_name_path, "") : null
  description = "SSM prefix"
}
