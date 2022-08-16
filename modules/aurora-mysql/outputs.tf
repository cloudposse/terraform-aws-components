output "cluster_domain" {
  value       = local.cluster_domain
  description = "AWS DNS name under which DB instances are provisioned"
}

output "aurora_mysql_master_username" {
  value       = local.mysql_enabled ? module.aurora_mysql.master_username : null
  description = "RDS Aurora-MySQL: Username for the master DB user"
  sensitive   = true
}

output "aurora_mysql_master_password" {
  value       = local.mysql_enabled ? "Password for admin user ${module.aurora_mysql.master_username} is stored in SSM at ${local.mysql_admin_password_key}" : null
  description = "Location of admin password"
  sensitive   = true
}

output "aurora_mysql_master_password_ssm_key" {
  value       = local.mysql_enabled ? local.mysql_admin_password_key : null
  description = "SSM key for admin password"
}

output "aurora_mysql_master_hostname" {
  value       = local.mysql_enabled ? module.aurora_mysql.master_host : null
  description = "RDS Aurora-MySQL: DB Master hostname"
}

output "aurora_mysql_replicas_hostname" {
  value       = local.mysql_enabled ? module.aurora_mysql.replicas_host : null
  description = "RDS Aurora-MySQL: Replicas hostname"
}

output "aurora_mysql_cluster_name" {
  value       = local.mysql_enabled ? module.aurora_mysql.cluster_identifier : null
  description = "RDS Aurora-MySQL: Cluster Identifier"
}

output "aurora_mysql_endpoint" {
  value       = local.mysql_enabled ? module.aurora_mysql.endpoint : null
  description = "RDS Aurora-MySQL: Endpoint"
}

output "aurora_mysql_reader_endpoint" {
  value       = local.mysql_enabled ? module.aurora_mysql.reader_endpoint : null
  description = "RDS Aurora-MySQL: Reader Endpoint"
}

output "kms_key_arn" {
  value       = module.kms_key_rds.key_arn
  description = "KMS key ARN for Aurora MySQL"
}
