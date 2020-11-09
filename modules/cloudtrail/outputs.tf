output "cloudtrail_id" {
  value       = module.cloudtrail.cloudtrail_id
  description = "CloudTrail ID"
}

output "cloudtrail_arn" {
  value       = module.cloudtrail.cloudtrail_arn
  description = "CloudTrail ARN"
}

output "cloudtrail_home_region" {
  value       = module.cloudtrail.cloudtrail_home_region
  description = "The region in which CloudTrail was created"
}

output "cloudtrail_logs_log_group_arn" {
  value       = aws_cloudwatch_log_group.cloudtrail_cloudwatch_logs.arn
  description = "CloudTrail Logs log group ARN"
}

output "cloudtrail_logs_log_group_name" {
  value       = aws_cloudwatch_log_group.cloudtrail_cloudwatch_logs.name
  description = "CloudTrail Logs log group name"
}

output "cloudtrail_logs_role_arn" {
  value       = aws_iam_role.cloudtrail_cloudwatch_logs.arn
  description = "CloudTrail Logs role ARN"
}

output "cloudtrail_logs_role_name" {
  value       = aws_iam_role.cloudtrail_cloudwatch_logs.name
  description = "CloudTrail Logs role name"
}
