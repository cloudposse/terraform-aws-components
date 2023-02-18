output "arn" {
  description = "ARN of the lambda function"
  value       = module.lambda.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the lambda function"
  value       = module.lambda.invoke_arn
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
  value       = module.lambda.qualified_arn
}

output "function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

output "role_name" {
  description = "Lambda IAM role name"
  value       = module.lambda.role_name
}

output "role_arn" {
  description = "Lambda IAM role ARN"
  value       = module.lambda.role_arn
}
