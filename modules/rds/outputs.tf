locals {
  ssm_path_as_list        = split("/", local.rds_database_password_path)
  ssm_path_app            = trim(join("/", slice(local.ssm_path_as_list, 0, length(local.ssm_path_as_list) - 1)), "/")
  ssm_path_password_value = element(local.ssm_path_as_list, length(local.ssm_path_as_list) - 1)
  psql_message            = <<EOT
  Use the following to connect to this RDS instance:
  (You must have access to read the SSM parameter, have access to the private network if necessary, and have security group access)

  PGPASSWORD=$(chamber read ${local.ssm_path_app} ${local.ssm_path_password_value} -q) psql --host=${module.rds_instance.instance_address} --port=${var.database_port} --username=${local.database_user} --dbname=${var.database_name}
  EOT
}

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

output "psql_helper" {
  value       = local.psql_access_enabled ? local.psql_message : ""
  description = "A helper output to use with psql for connecting to this RDS instance."
}

output "kms_key_alias" {
  value       = module.kms_key_rds.alias_name
  description = "The KMS key alias"
}
