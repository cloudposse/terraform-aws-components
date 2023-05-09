output "id" {
  description = "The Redshift Cluster ID"
  value       = local.enabled ? module.redshift_cluster.id : null
}

output "arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = local.enabled ? module.redshift_cluster.arn : null
}

output "cluster_identifier" {
  description = "The Cluster Identifier"
  value       = local.enabled ? module.redshift_cluster.cluster_identifier : null
}

output "port" {
  description = "The Port the cluster responds on"
  value       = local.enabled ? module.redshift_cluster.port : null
}

output "dns_name" {
  description = "The DNS name of the cluster"
  value       = local.enabled ? module.redshift_cluster.dns_name : null
}

output "vpc_security_group_ids" {
  description = "The VPC security group IDs associated with the cluster"
  value       = local.enabled ? module.redshift_cluster.vpc_security_group_ids : null
}

output "cluster_security_groups" {
  description = "The security groups associated with the cluster"
  value       = local.enabled ? module.redshift_cluster.cluster_security_groups : null
}

output "endpoint" {
  description = "The connection endpoint"
  value       = local.enabled ? module.redshift_cluster.endpoint : null
}

output "database_name" {
  description = "The name of the default database in the Cluster"
  value       = local.enabled ? module.redshift_cluster.database_name : null
}
