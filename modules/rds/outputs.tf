output "rds_name" {
  value       = local.enabled ? var.database_name : null
  description = "RDS DB name"
}

output "rds_port" {
  value       = local.enabled ? var.database_port : null
  description = "RDS DB port"
}

output "rds_id" {
  value       = local.enabled ? module.rds_instance.instance_id : null
  description = "ID of the instance"
}

output "rds_arn" {
  value       = local.enabled ? module.rds_instance.instance_arn : null
  description = "ARN of the instance"
}

output "rds_address" {
  value       = local.enabled ? module.rds_instance.instance_address : null
  description = "Address of the instance"
}

output "rds_endpoint" {
  value       = local.enabled ? module.rds_instance.instance_endpoint : null
  description = "DNS Endpoint of the instance"
}

output "rds_subnet_group_id" {
  value       = local.enabled ? module.rds_instance.subnet_group_id : null
  description = "ID of the created Subnet Group"
}

output "rds_security_group_id" {
  value       = local.enabled ? module.rds_instance.security_group_id : null
  description = "ID of the Security Group"
}

output "rds_parameter_group_id" {
  value       = local.enabled ? module.rds_instance.parameter_group_id : null
  description = "ID of the Parameter Group"
}

output "rds_option_group_id" {
  value       = local.enabled ? module.rds_instance.option_group_id : null
  description = "ID of the Option Group"
}

output "rds_hostname" {
  value       = local.enabled ? module.rds_instance.hostname : null
  description = "DNS host name of the instance"
}

output "rds_resource_id" {
  value       = local.enabled ? module.rds_instance.resource_id : null
  description = "The RDS Resource ID of this instance."
}

output "exports" {
  value = {
    security_groups = {
      client = var.client_security_group_enabled ? module.rds_client_sg.id : null
    }
  }
  description = "Map of exports for use in deployment configuration templates"
}
