output "primary_guardduty_detector_arn" {
  value       = local.enabled && local.is_global_collector_account ? module.guardduty_primary[0].guardduty_detector.arn : null
  description = "Primary GuardDuty detector ARN"
}

output "primary_guardduty_detector_id" {
  value       = local.enabled && local.is_global_collector_account ? module.guardduty_primary[0].guardduty_detector.id : null
  description = "Primary GuardDuty detector ID"
}

output "guardduty_detector_arn" {
  value       = local.enabled && !local.is_global_collector_account ? module.guardduty[0].guardduty_detector.arn : null
  description = "Member GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = local.enabled && !local.is_global_collector_account ? module.guardduty[0].guardduty_detector.id : null
  description = "Member GuardDuty detector ID"
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = local.create_sns_topic && local.is_global_collector_account ? module.guardduty_primary[0].sns_topic.name : null
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = local.create_sns_topic && local.is_global_collector_account ? module.guardduty_primary[0].sns_topic_subscriptions : null
}
