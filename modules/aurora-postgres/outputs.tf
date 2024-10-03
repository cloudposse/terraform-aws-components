output "database_name" {
  value       = local.database_name
  description = "Postgres database name"
}

output "admin_username" {
  value       = module.aurora_postgres_cluster.master_username
  description = "Postgres admin username"
  sensitive   = true
}

output "master_hostname" {
  value       = module.aurora_postgres_cluster.master_host
  description = "Postgres master hostname"
}

output "replicas_hostname" {
  value       = module.aurora_postgres_cluster.replicas_host
  description = "Postgres replicas hostname"
}

output "cluster_identifier" {
  value       = module.aurora_postgres_cluster.cluster_identifier
  description = "Postgres cluster identifier"
}

output "ssm_key_paths" {
  value       = module.parameter_store_write.names
  description = "Names (key paths) of all SSM parameters stored for this cluster"
}

output "config_map" {
  value = {
    cluster          = module.aurora_postgres_cluster.cluster_identifier
    database         = local.database_name
    hostname         = module.aurora_postgres_cluster.master_host
    port             = var.database_port
    endpoint         = module.aurora_postgres_cluster.endpoint
    username         = module.aurora_postgres_cluster.master_username
    password_ssm_key = local.admin_password_key
  }
  description = "Map containing information pertinent to a PostgreSQL client configuration."
  sensitive   = true
}

output "kms_key_arn" {
  value       = module.kms_key_rds.key_arn
  description = "KMS key ARN for Aurora Postgres"
}

output "allowed_security_groups" {
  value       = local.allowed_security_groups
  description = "The resulting list of security group IDs that are allowed to connect to the Aurora Postgres cluster."
}
