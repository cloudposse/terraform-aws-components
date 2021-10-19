output "autoscaling_group_arn" {
  description = "The Amazon Resource Name (ARN) of the Auto Scaling Group."
  value       = module.autoscale_group.autoscaling_group_arn
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group."
  value       = module.autoscale_group.autoscaling_group_name
}

output "autoscaling_lifecycle_hook_name" {
  description = "The name of the Lifecycle Hook for the Auto Scaling Group."
  value       = module.graceful_scale_in.autoscaling_lifecycle_hook_name
}

output "eventbridge_rule_arn" {
  description = "The ARN of the Eventbridge rule for the EC2 lifecycle transition."
  value       = module.graceful_scale_in.eventbridge_rule_arn
}

output "eventbridge_target_arn" {
  description = "The ARN of the Eventbridge target corresponding to the Eventbridge rule for the EC2 lifecycle transition."
  value       = module.graceful_scale_in.eventbridge_target_arn
}

output "ssm_document_arn" {
  description = "The ARN of the SSM document."
  value       = module.graceful_scale_in.ssm_document_arn
}