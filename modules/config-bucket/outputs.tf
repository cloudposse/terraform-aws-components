output "config_bucket_domain_name" {
  value       = module.config_bucket.bucket_domain_name
  description = "AWS Config FQDN of bucket"
}

output "config_bucket_id" {
  value       = module.config_bucket.bucket_id
  description = "AWS Config S3 bucket ID"
}

output "config_bucket_arn" {
  value       = module.config_bucket.bucket_arn
  description = "AWS Config S3 bucket ARN"
}