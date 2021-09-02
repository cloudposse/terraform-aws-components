output "cluster_id" {
  value       = module.redis.id
  description = "Redis cluster ID"
}

output "cluster_security_group_id" {
  value       = module.redis.security_group_id
  description = "Cluster Security Group ID"
}

output "cluster_endpoint" {
  value       = module.redis.endpoint
  description = "Redis primary endpoint"
}

output "cluster_host" {
  value       = module.redis.host
  description = "Redis hostname"
}
