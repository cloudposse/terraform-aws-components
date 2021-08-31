output "aurora_postgres_database_name" {
  value       = local.enabled ? local.database_name : null
  description = "Aurora Postgres Database name"
}

output "aurora_postgres_admin_username" {
  value       = local.enabled ? module.primary_aurora_postgres_cluster.master_username : null
  description = "Aurora Postgres Username for the master DB user"
}

output "aurora_postgres_admin_password_info" {
  value       = local.enabled ? "Postgres master password is stored in SSM under ${aws_ssm_parameter.primary_aurora_postgres_admin_password[0].id}" : null
  description = "Location of Postgres master password"
}

output "aurora_postgres_ssm_key_prefix" {
  value       = local.enabled ? local.ssm_key_prefix : null
  description = "SSM key prefix of all parameters stored for this cluster"
}

output "aurora_postgres_master_password_ssm_key" {
  value       = local.enabled ? aws_ssm_parameter.primary_aurora_postgres_admin_password[0].id : null
  description = "SSM key of Postgres master password"
}

output "primary_aurora_postgres_master_hostname" {
  value       = local.enabled ? module.primary_aurora_postgres_cluster.master_host : null
  description = "Primary Aurora Postgres DB Master hostname"
}

output "primary_aurora_postgres_replicas_hostname" {
  value       = local.enabled ? module.primary_aurora_postgres_cluster.replicas_host : null
  description = "Primary Aurora Postgres Replicas hostname"
}

output "primary_aurora_postgres_cluster_identifier" {
  value       = local.enabled ? module.primary_aurora_postgres_cluster.cluster_identifier : null
  description = "Primary Aurora Postgres Cluster Identifier"
}

output "primary_aurora_postgres_cluster_security_group_id" {
  value       = local.enabled ? module.primary_aurora_postgres_cluster.security_group_id : null
  description = "Primary Aurora Postgres Cluster Security Group"
}

output "secondary_aurora_postgres_replicas_hostname" {
  value       = local.enabled ? local.secondary_aurora_postgres_cluster_reader_endpoint : null
  description = "Secondary Aurora Postgres Replicas hostname"
}

output "secondary_aurora_postgres_cluster_identifier" {
  value       = local.enabled ? module.secondary_aurora_postgres_cluster.cluster_identifier : null
  description = "Secondary Aurora Postgres Cluster Identifier"
}

output "secondary_aurora_postgres_cluster_security_group_id" {
  value       = local.enabled ? module.secondary_aurora_postgres_cluster.security_group_id : null
  description = "Secondary Aurora Postgres Cluster Security Group"
}

