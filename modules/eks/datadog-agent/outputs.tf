output "metadata" {
  value       = local.enabled ? module.datadog_agent.metadata : null
  description = "Block status of the deployed release"
}

output "cluster_checks" {
  value       = local.datadog_cluster_checks
  description = "Cluster Checks for the cluster"
}
