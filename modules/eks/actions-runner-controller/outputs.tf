output "metadata" {
  value       = module.actions_runner_controller.metadata
  description = "Block status of the deployed release"

  precondition {
    condition = length([
      for k, v in var.runners : k if v.webhook_startup_timeout != null && v.max_duration != null
    ]) == 0
    error_message = <<-EOT
        The input var.runners[runner].webhook_startup_timeout is deprecated and replaced by var.runners[runner].max_duration.
        You may not set both values at the same time, but the following runners have both values set:
          ${join("\n  ", [for k, v in var.runners : k if v.webhook_startup_timeout != null && v.max_duration != null])}

       EOT
  }
  precondition {
    condition = length([
      for k, v in var.runners : k if v.storage != null && v.docker_storage != null
    ]) == 0
    error_message = <<-EOT
        The input var.runners[runner].storage is deprecated and replaced by var.runners[runner].docker_storage.
        You may not set both values at the same time, but the following runners have both values set:
          ${join("\n  ", [for k, v in var.runners : k if v.storage != null && v.docker_storage != null])}

       EOT
  }
}

output "metadata_action_runner_releases" {
  value       = local.enabled ? { for k, v in var.runners : k => module.actions_runner[k].metadata } : null
  description = "Block statuses of the deployed actions-runner chart releases"
}

output "webhook_payload_url" {
  value       = local.webhook_enabled ? format("https://${var.webhook.hostname_template}", var.tenant, var.stage, var.environment) : null
  description = "Payload URL for GitHub webhook"
}
