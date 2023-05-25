output "guardduty_detector_arn" {
  value       = join("", module.guardduty[*].guardduty_detector.arn)
  description = "GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = join("", module.guardduty[*].guardduty_detector.id)
  description = "GuardDuty detector ID"
}

output "sns_topic" {
  description = "SNS topic"
  value       = local.create_sns_topic ? join("", module.guardduty[*].sns_topic) : null
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = local.create_sns_topic ? join("", module.guardduty[*].sns_topic_subscriptions) : null
}
