output "url" {
  description = "The URL of the created Amazon SQS queue."
  value       = local.enabled ? aws_sqs_queue.default[0].url : null
}

output "id" {
  description = "The ID of the created Amazon SQS queue. Same as the URL."
  value       = local.enabled ? aws_sqs_queue.default[0].id : null
}

output "name" {
  description = "The name of the created Amazon SQS queue."
  value       = local.enabled ? module.this.id : null
}

output "arn" {
  description = "The ARN of the created Amazon SQS queue."
  value       = local.enabled ? aws_sqs_queue.default[0].arn : null
}
