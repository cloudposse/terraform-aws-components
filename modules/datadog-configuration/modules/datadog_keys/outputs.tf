output "datadog_api_key" {
  value = one(data.aws_ssm_parameter.datadog_api_key[*].value)
}

output "datadog_app_key" {
  value = one(data.aws_ssm_parameter.datadog_app_key[*].value)
}

output "datadog_api_url" {
  value = module.datadog_configuration.outputs.datadog_api_url
}

output "datadog_site" {
  value = module.datadog_configuration.outputs.datadog_site
}

output "api_key_ssm_arn" {
  value = one(data.aws_ssm_parameter.datadog_api_key[*].arn)
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
  description = "The Context Tags in datadog tag format (list of strings formated as 'key:value')"
}
