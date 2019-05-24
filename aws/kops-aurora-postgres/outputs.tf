output "aurora_postgres_database_name" {
  value       = "${module.aurora_postgres.name}"
  description = "Aurora Postgres Database name"
}

output "aurora_postgres_master_username" {
  value       = "${module.aurora_postgres.user}"
  description = "Aurora Postgres Username for the master DB user"
}

output "aurora_postgres_master_hostname" {
  value       = "${module.aurora_postgres.master_host}"
  description = "Aurora Postgres DB Master hostname"
}

output "aurora_postgres_replicas_hostname" {
  value       = "${module.aurora_postgres.replicas_host}"
  description = "Aurora Postgres Replicas hostname"
}

output "aurora_postgres_cluster_name" {
  value       = "${module.aurora_postgres.cluster_name}"
  description = "Aurora Postgres Cluster Identifier"
}
