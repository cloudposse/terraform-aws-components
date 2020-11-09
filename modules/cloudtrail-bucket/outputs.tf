output "cloudtrail_bucket_domain_name" {
  value       = module.cloudtrail_s3_bucket.bucket_domain_name
  description = "CloudTrail S3 bucket domain name"
}

output "cloudtrail_bucket_id" {
  value       = module.cloudtrail_s3_bucket.bucket_id
  description = "CloudTrail S3 bucket ID"
}

output "cloudtrail_bucket_arn" {
  value       = module.cloudtrail_s3_bucket.bucket_arn
  description = "CloudTrail S3 bucket ARN"
}
