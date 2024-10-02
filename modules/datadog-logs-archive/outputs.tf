output "bucket_arn" {
  value       = local.enabled ? module.archive_bucket[0].bucket_arn : ""
  description = "The ARN of the bucket used for log archive storage"
}

output "bucket_domain_name" {
  value       = local.enabled ? module.archive_bucket[0].bucket_domain_name : ""
  description = "The FQDN of the bucket used for log archive storage"
}

output "bucket_id" {
  value       = local.enabled ? module.archive_bucket[0].bucket_id : ""
  description = "The ID (name) of the bucket used for log archive storage"
}

output "bucket_region" {
  value       = local.enabled ? module.archive_bucket[0].bucket_region : ""
  description = "The region of the bucket used for log archive storage"
}

output "cloudtrail_bucket_arn" {
  value       = local.enabled ? module.cloudtrail_s3_bucket[0].bucket_arn : ""
  description = "The ARN of the bucket used for access logging via cloudtrail"
}

output "cloudtrail_bucket_domain_name" {
  value       = local.enabled ? module.cloudtrail_s3_bucket[0].bucket_domain_name : ""
  description = "The FQDN of the bucket used for access logging via cloudtrail"
}

output "cloudtrail_bucket_id" {
  value       = local.enabled ? module.cloudtrail_s3_bucket[0].bucket_id : ""
  description = "The ID (name) of the bucket used for access logging via cloudtrail"
}

output "archive_id" {
  value       = local.enabled ? datadog_logs_archive.logs_archive[0].id : ""
  description = "The ID of the environment-specific log archive"
}

output "catchall_id" {
  value       = local.enabled && var.catchall_enabled ? datadog_logs_archive.catchall_archive[0].id : ""
  description = "The ID of the catchall log archive"
}
