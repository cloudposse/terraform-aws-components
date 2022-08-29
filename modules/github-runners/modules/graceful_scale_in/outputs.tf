output "eventbridge_rule_arn" {
  description = "The ARN of the Eventbridge rule for the EC2 lifecycle transition."
  value       = join("", aws_cloudwatch_event_rule.default.*.arn)
}

output "eventbridge_target_arn" {
  description = "The ARN of the Eventbridge target corresponding to the Eventbridge rule for the EC2 lifecycle transition."
  value       = join("", aws_cloudwatch_event_target.default.*.arn)
}

output "autoscaling_lifecycle_hook_name" {
  description = "The name of the Lifecycle Hook for the Auto Scaling Group."
  value       = join("", aws_autoscaling_lifecycle_hook.default.*.name)
}

output "ssm_document_arn" {
  description = "The ARN of the SSM document."
  value       = join("", aws_ssm_document.default.*.arn)
}