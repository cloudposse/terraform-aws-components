output "url" {
  description = "The URL of the created Amazon SQS queue."
  value       = module.sqs_queue.url
}

output "id" {
  description = "The ID of the created Amazon SQS queue. Same as the URL."
  value       = module.sqs_queue.id
}

output "name" {
  description = "The name of the created Amazon SQS queue."
  value       = module.sqs_queue.name
}

output "arn" {
  description = "The ARN of the created Amazon SQS queue"
  value       = module.sqs_queue.arn
}
