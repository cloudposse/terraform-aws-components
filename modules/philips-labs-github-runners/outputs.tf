output "webhook" {
  description = "Information about the webhook to use to register the runner."
  value       = one(module.github_runner[*].webhook)
}

output "ssm_parameters" {
  description = "Information about the SSM parameters to use to register the runner."
  value       = one(module.github_runner[*].ssm_parameters)
}

output "github_runners" {
  description = "Information about the GitHub runners."
  value       = one(module.github_runner[*].runners)
}

output "queues" {
  description = "Information about the GitHub runner queues. Such as `build_queue_arn` the ARN of the SQS queue to use for the build queue."
  value       = one(module.github_runner[*].queues)
}
