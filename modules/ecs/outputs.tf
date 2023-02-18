output "cluster_arn" {
  value       = module.cluster.arn
  description = "ECS cluster ARN"
}

output "cluster_name" {
  value       = module.cluster.name
  description = "ECS Cluster Name"
}

output "vpc_id" {
  value       = module.vpc.outputs.vpc_id
  description = "VPC ID"
}

output "security_group_id" {
  value       = module.vpc.outputs.vpc_default_security_group_id
  description = "Security group id"
}

output "public_subnet_ids" {
  value       = module.vpc.outputs.public_subnet_ids
  description = "Public subnet ids"
}

output "private_subnet_ids" {
  value       = module.vpc.outputs.private_subnet_ids
  description = "Private subnet ids"
}

output "alb" {
  value       = module.alb
  description = "ALB outputs"
}

output "records" {
  value       = local.dns_enabled ? { for record, value in aws_route53_record.default : record => value.fqdn } : {}
  description = "Record names"
}
