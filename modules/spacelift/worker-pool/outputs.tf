output "worker_pool_id" {
  value       = join("", spacelift_worker_pool.primary[*].id)
  description = "Spacelift worker pool ID"
}

output "worker_pool_name" {
  value       = join("", spacelift_worker_pool.primary[*].name)
  description = "Spacelift worker pool name"
}

output "security_group_id" {
  description = "Spacelift Security Group ID"
  value       = module.security_group.id
}

output "security_group_arn" {
  description = "Spacelift Security Group ARN"
  value       = module.security_group.arn
}

output "security_group_name" {
  description = "Spacelift Security Group Name"
  value       = module.security_group.name
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.autoscale_group.launch_template_id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.autoscale_group.launch_template_arn
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.autoscale_group.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.autoscale_group.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.autoscale_group.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = module.autoscale_group.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = module.autoscale_group.autoscaling_group_max_size
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.autoscale_group.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.autoscale_group.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = module.autoscale_group.autoscaling_group_health_check_type
}

output "iam_role_name" {
  value       = join("", aws_iam_role.default[*].name)
  description = "Spacelift IAM Role name"
}

output "iam_role_id" {
  value       = join("", aws_iam_role.default[*].unique_id)
  description = "Spacelift IAM Role ID"
}

output "iam_role_arn" {
  value       = join("", aws_iam_role.default[*].arn)
  description = "Spacelift IAM Role ARN"
}
