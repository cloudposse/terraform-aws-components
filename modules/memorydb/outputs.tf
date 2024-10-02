output "id" {
  description = "The name of the MemoryDB cluster"
  value       = module.memorydb.id
}

output "arn" {
  description = "The ARN of the MemoryDB cluster"
  value       = module.memorydb.arn
}

output "cluster_endpoint" {
  description = "The endpoint of the MemoryDB cluster"
  value       = module.memorydb.cluster_endpoint
}

output "engine_patch_version" {
  description = "The Redis engine version"
  value       = module.memorydb.engine_patch_version
}

output "parameter_group_id" {
  description = "The name of the MemoryDB parameter group"
  value       = module.memorydb.id
}

output "parameter_group_arn" {
  description = "The ARN of the MemoryDB parameter group"
  value       = module.memorydb.arn
}

output "subnet_group_id" {
  description = "The name of the MemoryDB subnet group"
  value       = module.memorydb.id
}

output "subnet_group_arn" {
  description = "The ARN of the MemoryDB subnet group"
  value       = module.memorydb.arn
}

output "shards" {
  description = "The shard details for the MemoryDB cluster"
  value       = module.memorydb.shards
}

output "admin_username" {
  description = "The username for the MemoryDB user"
  value       = module.memorydb.admin_username
}

output "admin_arn" {
  description = "The ARN of the MemoryDB user"
  value       = module.memorydb.admin_arn
}

output "admin_acl_arn" {
  description = "The ARN of the MemoryDB user's ACL"
  value       = module.memorydb.admin_acl_arn
}

output "admin_password_ssm_parameter_name" {
  description = "The name of the SSM parameter storing the password for the MemoryDB user"
  value       = module.memorydb.admin_password_ssm_parameter_name
}
