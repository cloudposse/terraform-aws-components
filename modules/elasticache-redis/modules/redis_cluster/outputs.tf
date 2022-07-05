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

output "cluster_port" {
  value       = module.redis.port
  description = "Redis port"
}

output "cluster_ssm_path_auth_token" {
  value       = local.ssm_path_auth_token
  description = "SSM path of Redis auth_token"
}
