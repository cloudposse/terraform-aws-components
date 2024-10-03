output "datadog_api_key" {
  value       = one(data.aws_ssm_parameter.datadog_api_key[*].value)
  description = "Datadog API Key"
}

output "datadog_app_key" {
  value       = one(data.aws_ssm_parameter.datadog_app_key[*].value)
  description = "Datadog APP Key"
}

output "datadog_api_url" {
  value       = module.datadog_configuration.outputs.datadog_api_url
  description = "Datadog API URL"
}

output "datadog_site" {
  value       = module.datadog_configuration.outputs.datadog_site
  description = "Datadog Site"
}

output "api_key_ssm_arn" {
  value       = one(data.aws_ssm_parameter.datadog_api_key[*].arn)
  description = "Datadog API Key SSM ARN"
}

output "datadog_secrets_store_type" {
  value       = module.datadog_configuration.outputs.datadog_secrets_store_type
  description = "The type of the secrets store to use for Datadog API and APP keys"
}

output "datadog_app_key_location" {
  value       = module.datadog_configuration.outputs.datadog_app_key_location
  description = "The Datadog APP key location in the secrets store"
}

output "datadog_api_key_location" {
  value       = module.datadog_configuration.outputs.datadog_api_key_location
  description = "The Datadog API key in the secrets store"
}

output "datadog_tags" {
  value       = local.dd_tags
  description = "The Context Tags in datadog tag format (list of strings formatted as 'key:value')"
}
