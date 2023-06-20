output "delegated_administrator_account_id" {
  value       = local.org_delegated_administrator_account_id
  description = "The AWS Account ID of the AWS Organization delegated administrator account"
}

output "guardduty_detector_arn" {
  value       = local.create_guardduty_collector ? try(module.guardduty[0].guardduty_detector.arn, null) : null
  description = "The ARN of the GuardDuty detector created by the component"
}

output "guardduty_detector_id" {
  value       = local.create_guardduty_collector ? try(module.guardduty[0].guardduty_detector.id, null) : null
  description = "The ID of the GuardDuty detector created by the component"
}

output "sns_topic_name" {
  value       = local.create_guardduty_collector ? try(module.guardduty[0].sns_topic.name, null) : null
  description = "The name of the SNS topic created by the component"
}

output "sns_topic_subscriptions" {
  value       = local.create_guardduty_collector ? try(module.guardduty[0].sns_topic_subscriptions, null) : null
  description = "The SNS topic subscriptions created by the component"
}
