output "guardduty_detector_arn" {
  value       = local.create_guardduty_collector ? try(module.guardduty[0].guardduty_detector.arn, null) : null
  description = "Member GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = local.create_guardduty_collector ? try(module.guardduty[0].guardduty_detector.id, null) : null
  description = "Member GuardDuty detector ID"
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = local.create_guardduty_collector ? try(module.guardduty[0].sns_topic.name, null) : null
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = local.create_guardduty_collector ? try(module.guardduty[0].sns_topic_subscriptions, null) : null
}
