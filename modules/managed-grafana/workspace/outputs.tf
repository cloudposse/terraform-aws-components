output "workspace_id" {
  description = "The ID of the Amazon Managed Grafana workspace"
  value       = module.managed_grafana.workspace_id
}

output "workspace_endpoint" {
  description = "The returned URL of the Amazon Managed Grafana workspace"
  value       = module.managed_grafana.workspace_endpoint
}
