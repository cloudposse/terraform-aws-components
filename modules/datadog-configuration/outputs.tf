output "region" {
  value       = var.region
  description = "The region where the keys will be created"
}

output "datadog_secrets_store_type" {
  value       = var.datadog_secrets_store_type
  description = "The type of the secrets store to use for Datadog API and APP keys"
}

output "datadog_api_url" {
  value       = local.datadog_api_url
  description = "The URL of the Datadog API"
}

output "datadog_app_key_location" {
  value       = local.datadog_app_key_name
  description = "The Datadog APP key location in the secrets store"
}

output "datadog_api_key_location" {
  value       = local.datadog_api_key_name
  description = "The Datadog API key in the secrets store"
}

output "datadog_site" {
  value       = local.datadog_site
  description = "The Datadog site to use"
}
