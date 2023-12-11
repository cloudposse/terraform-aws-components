output "metadata" {
  value       = module.actions_runner_controller.metadata
  description = "Block status of the deployed release"
}

output "metadata_action_runner_releases" {
  value       = local.enabled ? { for k, v in var.runners : k => module.actions_runner[k].metadata } : null
  description = "Block statuses of the deployed actions-runner chart releases"
}

output "webhook_payload_url" {
  value       = local.webhook_enabled ? format("https://${var.webhook.hostname_template}", var.tenant, var.stage, var.environment) : null
  description = "Payload URL for GitHub webhook"
}

output "iam_role_arn" {
  value       = one(resource.aws_iam_role.default[*].arn)
  description = "Arn of the created iam role"
}
