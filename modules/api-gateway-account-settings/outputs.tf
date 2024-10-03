output "role_arn" {
  description = "Role ARN of the API Gateway logging role"
  value       = module.api_gateway_account_settings.role_arn
}
