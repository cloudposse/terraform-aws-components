output "redis_clusters" {
  description = "Redis cluster objects"
  value       = local.clusters
}

output "redis_cluster_ids" {
  description = "Redis cluster ids"
  value       = compact(flatten([for cluster in local.clusters : cluster.cluster_id]))
}

output "redis_cluster_endpoints" {
  description = "Redis cluster endpoints"
  value       = [for cluster in local.clusters : { (cluster.cluster_id) = cluster.cluster_endpoint }]
}

output "redis_cluster_hosts" {
  description = "Redis cluster hosts"
  value       = [for cluster in local.clusters : { (cluster.cluster_id) = cluster.cluster_host }]
}
