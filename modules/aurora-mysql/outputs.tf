output "aurora_mysql_cluster_arn" {
  value       = module.aurora_mysql.arn
  description = "The ARN of Aurora cluster"
}

output "aurora_mysql_cluster_id" {
  value       = module.cluster.id
  description = "The ID of Aurora cluster"
}

output "aurora_mysql_cluster_name" {
  value       = local.enabled ? module.aurora_mysql.cluster_identifier : null
  description = "Aurora MySQL cluster identifier"
}

output "aurora_mysql_endpoint" {
  value       = local.enabled ? module.aurora_mysql.endpoint : null
  description = "Aurora MySQL endpoint"
}

output "aurora_mysql_master_hostname" {
  value       = local.enabled ? module.aurora_mysql.master_host : null
  description = "Aurora MySQL DB master hostname"
}

output "aurora_mysql_master_password" {
  value       = local.mysql_db_enabled ? "Password for admin user ${module.aurora_mysql.master_username} is stored in SSM at ${local.mysql_admin_password_key}" : null
  description = "Location of admin password in SSM"
  sensitive   = true
}

output "aurora_mysql_master_password_ssm_key" {
  value       = local.mysql_db_enabled ? local.mysql_admin_password_key : null
  description = "SSM key for admin password"
}

output "aurora_mysql_master_username" {
  value       = local.enabled ? module.aurora_mysql.master_username : null
  description = "Aurora MySQL username for the master DB user"
  sensitive   = true
}

output "aurora_mysql_reader_endpoint" {
  value       = local.enabled ? module.aurora_mysql.reader_endpoint : null
  description = "Aurora MySQL reader endpoint"
}

output "aurora_mysql_replicas_hostname" {
  value       = local.enabled ? module.aurora_mysql.replicas_host : null
  description = "Aurora MySQL replicas hostname"
}

output "cluster_domain" {
  value       = local.cluster_domain
  description = "Cluster DNS name"
}

output "kms_key_arn" {
  value       = module.kms_key_rds.key_arn
  description = "KMS key ARN for Aurora MySQL"
}

