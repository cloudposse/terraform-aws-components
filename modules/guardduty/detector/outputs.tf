output "guardduty_detector_arn" {
  value       = module.guardduty[0].guardduty_detector.arn
  description = "GuardDuty detector ARN"
}

output "guardduty_detector_id" {
  value       = module.guardduty[0].guardduty_detector.id
  description = "GuardDuty detector ID"
}