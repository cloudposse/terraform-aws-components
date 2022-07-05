output "master_username" {
  value       = module.documentdb_cluster.master_username
  description = "Username for the master DB user"
  sensitive   = true
}

output "cluster_name" {
  value       = module.documentdb_cluster.cluster_name
  description = "Cluster Identifier"
}

output "arn" {
  value       = module.documentdb_cluster.arn
  description = "Amazon Resource Name (ARN) of the cluster"
}

output "endpoint" {
  value       = module.documentdb_cluster.endpoint
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = module.documentdb_cluster.reader_endpoint
  description = "A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = module.documentdb_cluster.master_host
  description = "DB master hostname"
}

output "replicas_host" {
  value       = module.documentdb_cluster.replicas_host
  description = "DB replicas hostname"
}

output "security_group_id" {
  value       = module.documentdb_cluster.security_group_id
  description = "ID of the DocumentDB cluster Security Group"
}

output "security_group_arn" {
  value       = module.documentdb_cluster.security_group_arn
  description = "ARN of the DocumentDB cluster Security Group"
}

output "security_group_name" {
  value       = module.documentdb_cluster.security_group_name
  description = "Name of the DocumentDB cluster Security Group"
}
