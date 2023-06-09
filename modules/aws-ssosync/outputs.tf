output "arn" {
  description = "ARN of the lambda function"
  value       = join("", aws_lambda_function.ssosync.*.arn)
}

output "invoke_arn" {
  description = "Invoke ARN of the lambda function"
  value       = join("", aws_lambda_function.ssosync.*.invoke_arn)
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
  value       = join("", aws_lambda_function.ssosync.*.qualified_arn)
}
