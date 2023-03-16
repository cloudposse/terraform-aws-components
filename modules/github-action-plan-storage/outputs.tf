
output "iam_role_name" {
  value = aws_iam_role.default.name
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "plan_storage_dynamodb_table_name" {
  description = "Terraform plan storage DynamoDB table name"
  value       = join("", aws_dynamodb_table.default.*.name)
}

output "plan_storage_dynamodb_table_arn" {
  description = "Terraform plan storage DynamoDB table ARN"
  value       = join("", aws_dynamodb_table.default.*.arn)
}

output "tfstate_backend_s3_bucket_arn" {
  description = "Terraform state S3 bucket ARN"
  value       = module.tfstate_backend.tfstate_backend_s3_bucket_arn
}

output "tfstate_backend_dynamodb_table_arn" {
  description = "Terraform state DynamoDB table ARN"
  value       = module.tfstate_backend.tfstate_backend_dynamodb_table_arn
}

output "tfstate_backend_s3_bucket_id" {
  description = "Terraform state S3 bucket name"
  value       = module.tfstate_backend.tfstate_backend_s3_bucket_id
}

output "tfstate_backend_dynamodb_table_name" {
  description = "Terraform state DynamoDB table name"
  value       = module.tfstate_backend.tfstate_backend_dynamodb_table_name
}