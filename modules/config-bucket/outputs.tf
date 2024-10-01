output "config_bucket_domain_name" {
  value       = module.config_bucket.bucket_domain_name
  description = "Config bucket FQDN"
}

output "config_bucket_id" {
  value       = module.config_bucket.bucket_id
  description = "Config bucket ID"
}

output "config_bucket_arn" {
  value       = module.config_bucket.bucket_arn
  description = "Config bucket ARN"
}
