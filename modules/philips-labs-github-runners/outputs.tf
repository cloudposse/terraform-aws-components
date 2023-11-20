output "webhook" {
  description = "Information about the webhook to use to register the runner."
  value       = one(module.github_runner[*].webhook)
}

output "ssm_parameters" {
  value = one(module.github_runner[*].ssm_parameters)
}

output "github_runners" {
  value = one(module.github_runner[*].runners)
}

output "queues" {
  value = one(module.github_runner[*].queues)
}
