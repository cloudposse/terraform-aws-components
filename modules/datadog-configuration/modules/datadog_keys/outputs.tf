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

output "datadog_tags" {
  value       = local.dd_tags
  description = "The Context Tags in datadog tag format (list of strings formated as 'key:value')"
}
