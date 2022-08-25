output "redis_clusters" {
  description = "Redis cluster objects"
  value       = local.enabled ? local.clusters : {}
}
