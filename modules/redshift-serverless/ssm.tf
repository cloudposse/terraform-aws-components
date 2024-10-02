resource "aws_ssm_parameter" "admin_user" {
  count = local.enabled ? 1 : 0

  name        = format("/%s/%s", var.ssm_path_prefix, "admin_user")
  value       = local.admin_user
  description = "Redshift cluster admin username"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "admin_password" {
  count = local.enabled ? 1 : 0

  name        = format("/%s/%s", var.ssm_path_prefix, "admin_password")
  value       = local.admin_password
  description = "Redshift cluster admin password"
  type        = "SecureString"
  key_id      = var.kms_alias_name_ssm
  overwrite   = true
}

resource "aws_ssm_parameter" "endpoint" {
  count = local.enabled ? 1 : 0

  name        = format("/%s/%s", var.ssm_path_prefix, "endpoint")
  value       = aws_redshiftserverless_workgroup.default[0].endpoint[0].address
  description = "Redshift endpoint address"
  type        = "String"
  overwrite   = true
}
