output "tfstate_backend_s3_bucket_domain_name" {
  description = "Terraform state S3 bucket domain name"
  value       = module.tfstate_backend.s3_bucket_domain_name
}

output "tfstate_backend_s3_bucket_id" {
  description = "Terraform state S3 bucket ID"
  value       = module.tfstate_backend.s3_bucket_id
}

output "tfstate_backend_s3_bucket_arn" {
  description = "Terraform state S3 bucket ARN"
  value       = module.tfstate_backend.s3_bucket_arn
}

output "tfstate_backend_dynamodb_table_name" {
  description = "Terraform state DynamoDB table name"
  value       = module.tfstate_backend.dynamodb_table_name
}

output "tfstate_backend_dynamodb_table_id" {
  description = "Terraform state DynamoDB table ID"
  value       = module.tfstate_backend.dynamodb_table_id
}

output "tfstate_backend_dynamodb_table_arn" {
  description = "Terraform state DynamoDB table ARN"
  value       = module.tfstate_backend.dynamodb_table_arn
}

output "tfstate_backend_access_role_arns" {
  value       = { for k, v in aws_iam_role.default : k => v.arn }
  description = "IAM Role ARNs for accessing the Terraform State Backend"
}
