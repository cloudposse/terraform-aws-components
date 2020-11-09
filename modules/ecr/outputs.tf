output "ecr_repo_arn_map" {
  value       = module.ecr.repository_arn_map
  description = "Map of image names to ARNs"
}

output "ecr_repo_url_map" {
  value       = module.ecr.repository_url_map
  description = "Map of image names to URLs"
}
