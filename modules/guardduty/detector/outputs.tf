output "guardduty_detector_arn" {
  value       = join("", module.guardduty[*].guardduty_detector.arn)
  description = "GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = join("", module.guardduty[*].guardduty_detector.id)
  description = "GuardDuty detector ID"
}