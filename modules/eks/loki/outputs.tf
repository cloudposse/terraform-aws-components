output "metadata" {
  value       = module.loki.metadata
  description = "Block status of the deployed release"
}

output "id" {
  value       = module.this.id
  description = "The ID of this deployment"
}

output "url" {
  value       = local.ingress_host_name
  description = "The hostname used for this Loki deployment"
}

output "basic_auth_username" {
  value       = random_pet.basic_auth_username[0].id
  description = "If enabled, the username for basic auth"
}

output "ssm_path_basic_auth_password" {
  value       = local.ssm_path_password
  description = "If enabled, the path in AWS SSM to find the password for basic auth"
}
