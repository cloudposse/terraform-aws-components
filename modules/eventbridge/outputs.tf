output "cloudwatch_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group"
  value       = one(module.cloudwatch_logs[*].log_group_arn)
}

output "cloudwatch_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group"
  value       = one(module.cloudwatch_logs[*].log_group_name)
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule"
  value       = one(module.cloudwatch_event[*].cloudwatch_event_rule_arn)
}

output "cloudwatch_event_rule_name" {
  description = "The name of the CloudWatch Event Rule"
  value       = one(module.cloudwatch_event[*].cloudwatch_event_rule_id)
}
