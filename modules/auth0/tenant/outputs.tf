output "domain_ssm_path" {
  value       = local.auth0_domain_ssm_path
  description = "The SSM parameter path for the Auth0 domain"
}

output "client_id_ssm_path" {
  value       = local.auth0_client_id_ssm_path
  description = "The SSM parameter path for the Auth0 client ID"
}

output "client_secret_ssm_path" {
  value       = local.auth0_client_secret_ssm_path
  description = "The SSM parameter path for the Auth0 client secret"
}

output "auth0_domain" {
  value       = local.domain_name
  description = "The Auth0 custom domain"
}
