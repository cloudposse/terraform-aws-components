output "database_name" {
  value       = local.database_name
  description = "Postgres database name"
}

output "admin_username" {
  value       = module.aurora_postgres_cluster.master_username
  description = "Postgres admin username"
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
    username         = module.aurora_postgres_cluster.master_username
    password_ssm_key = format("%s/%s", local.ssm_cluster_key_prefix, "admin_password")
  }
  description = "Map containing information pertinent to a PostgreSQL client configuration."
}

output "additional_users" {
  value       = local.sanitized_additional_users
  description = "Information about additional DB users created by request"
}
