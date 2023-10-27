output "guardduty_detector_arn" {
  value       = one(module.guardduty[*].guardduty_detector.arn)
  description = "GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = one(module.guardduty[*].guardduty_detector.id)
  description = "GuardDuty detector ID"
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = one(module.guardduty[*].sns_topic.name)
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = one(module.guardduty[*].sns_topic_subscriptions)
}
