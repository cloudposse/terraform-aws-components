output "ssm_path_grafana_api_key" {
  description = "The path in AWS SSM to the Grafana API Key provisioned with this component"
  value       = local.ssm_path_api_key
}
