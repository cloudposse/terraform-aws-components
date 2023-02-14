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

resource "aws_ssm_parameter" "dns_name" {
  count = local.enabled ? 1 : 0

  name        = format("/%s/%s", var.ssm_path_prefix, "dns_name")
  value       = module.redshift_cluster.dns_name
  description = "Redshift cluster DNS name"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "endpoint" {
  count = local.enabled ? 1 : 0

  name        = format("/%s/%s", var.ssm_path_prefix, "endpoint")
  value       = module.redshift_cluster.endpoint
  description = "Redshift cluster endpoint"
  type        = "String"
  overwrite   = true
}
