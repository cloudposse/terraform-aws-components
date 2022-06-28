output "url" {
  description = "The URL for the created Amazon SQS queue."
  value       = module.sqs_queue.url
}

output "id" {
  description = "The ID for the created Amazon SQS queue. Same as the URL."
  value       = module.sqs_queue.id
}

output "name" {
  description = "The name for the created Amazon SQS queue."
  value       = module.sqs_queue.name
}

output "arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs_queue.arn
}
