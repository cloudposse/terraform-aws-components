output "arn" {
  description = "ARN of the lambda function"
  value       = local.enabled ? aws_lambda_function.ssosync[*].arn : null
}

output "invoke_arn" {
  description = "Invoke ARN of the lambda function"
  value       = local.enabled ? aws_lambda_function.ssosync[*].invoke_arn : null
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
  value       = local.enabled ? aws_lambda_function.ssosync[*].qualified_arn : null
}
