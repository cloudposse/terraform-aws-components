output "ssm_path" {
  value       = local.ssm_path
  description = "Full SSM path of the team integration key"
}

output "type" {
  value       = var.type
  description = "Type of the team integration"
}
