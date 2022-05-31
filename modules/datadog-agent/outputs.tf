output "metadata" {
  value       = module.datadog_agent.metadata
  description = "Block status of the deployed release"
}

output "cluster_checks" {
  value = local.datadog_cluster_checks
}
