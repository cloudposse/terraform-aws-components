output "log_group_arn" {
  description = "ARN of the log group"
  value       = module.logs.log_group_arn
}

output "stream_arns" {
  description = "ARN of the log stream"
  value       = module.logs.stream_arns
}

output "log_group_name" {
  description = "Name of log group"
  value       = module.logs.log_group_name
}

output "role_arn" {
  description = "ARN of role to assume"
  value       = module.logs.role_arn
}

output "role_name" {
  description = "Name of role to assume"
  value       = module.logs.role_name
}
