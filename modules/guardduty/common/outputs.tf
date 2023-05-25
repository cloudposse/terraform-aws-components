output "guardduty_detector_arn" {
  value       = local.enabled ? module.guardduty[0].guardduty_detector.arn : null
  description = "GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = local.enabled ? module.guardduty[0].guardduty_detector.id : null
  description = "GuardDuty detector ID"
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = local.create_sns_topic ? module.guardduty[0].sns_topic.name : null
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = local.create_sns_topic ? module.guardduty[0].sns_topic_subscriptions : null
}
