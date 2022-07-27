output "s3_bucket_id" {
  description = "ID of S3 bucket used by Athena."
  value       = module.athena.s3_bucket_id
}

output "kms_key_arn" {
  description = "ARN of KMS key used by Athena."
  value       = module.athena.kms_key_arn
}

output "workgroup_id" {
  description = "ID of newly created Athena workgroup."
  value       = module.athena.workgroup_id
}

output "databases" {
  description = "List of newly created Athena databases."
  value       = module.athena.databases
}

output "data_catalogs" {
  description = "List of newly created Athena data catalogs."
  value       = module.athena.data_catalogs
}

output "named_queries" {
  description = "List of newly created Athena named queries."
  value       = module.athena.named_queries
}
