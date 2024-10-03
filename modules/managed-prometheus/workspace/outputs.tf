output "id" {
  description = "The ID of this component deployment"
  value       = module.this.id
}

output "workspace_id" {
  description = "The ID of this Amazon Managed Prometheus workspace"
  value       = module.managed_prometheus.workspace_id
}

output "workspace_arn" {
  description = "The ARN of this Amazon Managed Prometheus workspace"
  value       = module.managed_prometheus.workspace_arn
}

output "workspace_endpoint" {
  description = "The endpoint URL of this Amazon Managed Prometheus workspace"
  value       = module.managed_prometheus.workspace_endpoint
}

output "workspace_region" {
  description = "The region where this workspace is deployed"
  value       = var.region
}

output "access_role_arn" {
  description = "If enabled with `var.allowed_account_id`, the Role ARN used for accessing Amazon Managed Prometheus in this account"
  value       = module.managed_prometheus.access_role_arn
}
