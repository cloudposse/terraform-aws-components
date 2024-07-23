output "origin_s3_bucket_name" {
  value       = module.spa_web.s3_bucket
  description = "Origin bucket name."
}

output "origin_s3_bucket_arn" {
  value       = module.spa_web.s3_bucket_arn
  description = "Origin bucket ARN."
}

output "cloudfront_distribution_domain_name" {
  value       = module.spa_web.cf_domain_name
  description = "Cloudfront Distribution Domain Name."
}

output "cloudfront_distribution_alias" {
  value       = module.spa_web.aliases
  description = "Cloudfront Distribution Alias Record."
}

output "cloudfront_distribution_identity_arn" {
  value       = module.spa_web.cf_identity_iam_arn
  description = "CloudFront Distribution Origin Access Identity IAM ARN."
}

output "failover_s3_bucket_name" {
  value       = try(data.aws_s3_bucket.failover_bucket[0].bucket, null)
  description = "Failover Origin bucket name, if enabled."
}
