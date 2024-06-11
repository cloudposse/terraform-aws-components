output "scraper_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role that provides permissions for the scraper to discover, collect, and produce metrics"
  value       = local.aps_clusterrole_username
}

output "clusterrole_username" {
  description = "The username of the ClusterRole used to give the scraper in-cluster permissions"
  value       = local.aps_clusterrole_identity
}
