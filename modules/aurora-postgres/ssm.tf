module "parameter_store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.8.3"

  # kms_arn will only be used for SecureString parameters
  kms_arn = var.kms_alias_name_ssm # not necessarily ARN — alias works too
  parameter_write = [
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "database_name")
      value       = local.database_name
      description = "Aurora Postgres database name"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "database_port")
      value       = var.database_port
      description = "Aurora Postgres database name"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "admin_username")
      value       = module.aurora_postgres_cluster.master_username
      description = "Aurora Postgres admin username"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "admin_password")
      value       = local.admin_password
      description = "Aurora Postgres admin password"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "admin/db_username")
      value       = module.aurora_postgres_cluster.master_username
      description = "Aurora Postgres Username for the admin DB user"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "admin/db_password")
      value       = local.admin_password
      description = "Aurora Postgres Password for the admin DB user"
      type        = "SecureString"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "master_hostname")
      value       = module.aurora_postgres_cluster.master_host
      description = "Aurora Postgres DB Master hostname"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "replicas_hostname")
      value       = module.aurora_postgres_cluster.replicas_host
      description = "Aurora Postgres DB Replicas hostname"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "cluster_id")
      value       = module.aurora_postgres_cluster.cluster_identifier
      description = "Aurora Postgres DB Cluster Identifier"
      type        = "String"
      overwrite   = true
    },
    {
      name        = format("%s/%s", local.ssm_cluster_key_prefix, "db_port")
      value       = var.database_port
      description = "Aurora Postgres DB Master port"
      type        = "String"
      overwrite   = true
    }
  ]

  context = module.this.context
}
