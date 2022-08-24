data "aws_ssm_parameter" "password" {
  count = local.fetch_admin_password ? 1 : 0

  name = format(var.ssm_password_source, local.mysql_admin_user)

  with_decryption = true
}

module "parameter_store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  # kms_arn will only be used for SecureString parameters
  kms_arn = module.kms_key_rds.key_arn

  parameter_write = [
    {
      name        = format("%s/%s/%s", local.ssm_cluster_key_prefix, "aurora-mysql", "cluster_domain")
      value       = local.cluster_domain
      description = "AWS DNS name under which DB instances are provisioned"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/admin/%s/%s", local.ssm_cluster_key_prefix, "aurora-mysql", "user")
      value       = local.mysql_admin_user
      description = "Aurora MySQL DB admin user"
      type        = "String"
      overwrite   = true
    },
    {
      name        = local.mysql_admin_password_key
      value       = local.mysql_admin_password
      description = "Aurora MySQL DB admin password"
      type        = "SecureString"
      overwrite   = true
    },
    {
      name        = format("%s/%s/%s", local.ssm_cluster_key_prefix, "aurora-mysql", "db_host")
      value       = module.aurora_mysql.master_host
      description = "Aurora MySQL DB Master hostname"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s/%s", local.ssm_cluster_key_prefix, "aurora-mysql", "db_port")
      value       = "3306"
      description = "Aurora MySQL DB Master TCP port"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s/%s", local.ssm_cluster_key_prefix, "aurora-mysql", "replicas_hostname")
      value       = module.aurora_mysql.replicas_host
      description = "Aurora MySQL DB Replicas hostname"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s/%s", local.ssm_cluster_key_prefix, "aurora-mysql", "cluster_name")
      value       = module.aurora_mysql.cluster_identifier
      description = "Aurora MySQL DB Cluster Identifier"
      type        = "String"
      overwrite   = true
    }
  ]

  context = module.this.context
}

