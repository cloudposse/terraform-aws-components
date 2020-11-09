output "tfstate_backend_s3_bucket_domain_name" {
  value       = module.tfstate_backend.s3_bucket_domain_name
  description = "Terraform state S3 bucket domain name"
}

output "tfstate_backend_s3_bucket_id" {
  value       = module.tfstate_backend.s3_bucket_id
  description = "Terraform state S3 bucket ID"
}

output "tfstate_backend_s3_bucket_arn" {
  value       = module.tfstate_backend.s3_bucket_arn
  description = "Terraform state S3 bucket ARN"
}

output "tfstate_backend_dynamodb_table_name" {
  value       = module.tfstate_backend.dynamodb_table_name
  description = "Terraform state DynamoDB table name"
}

output "tfstate_backend_dynamodb_table_id" {
  value       = module.tfstate_backend.dynamodb_table_id
  description = "Terraform state DynamoDB table ID"
}

output "tfstate_backend_dynamodb_table_arn" {
  value       = module.tfstate_backend.dynamodb_table_arn
  description = "Terraform state DynamoDB table ARN"
}
