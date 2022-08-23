output "dms_redshift_s3_role_arn" {
  value       = module.dms_iam.dms_redshift_s3_role_arn
  description = "DMS Redshift S3 role ARN"
}

output "dms_cloudwatch_logs_role_arn" {
  value       = module.dms_iam.dms_cloudwatch_logs_role_arn
  description = "DMS CloudWatch Logs role ARN"
}

output "dms_vpc_management_role_arn" {
  value       = module.dms_iam.dms_vpc_management_role_arn
  description = "DMS VPC management role ARN"
}
