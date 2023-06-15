module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.1"

  context = module.this.context

  acl                = "private"
  enabled            = local.enabled
  user_enabled       = false
  versioning_enabled = true
}

output "bucket_id" {
  value       = module.s3_bucket.bucket_id
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = module.s3_bucket.bucket_arn
  description = "Bucket ARN"
}

output "bucket_region" {
  value       = module.s3_bucket.bucket_region
  description = "Bucket region"
}
