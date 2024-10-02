output "connection_id" {
  description = "Glue connection ID"
  value       = module.glue_connection.id
}

output "connection_name" {
  description = "Glue connection name"
  value       = module.glue_connection.name
}

output "connection_arn" {
  description = "Glue connection ARN"
  value       = module.glue_connection.arn
}

output "security_group_id" {
  description = "The ID of the Security Group associated with the Glue connection"
  value       = module.security_group.id
}

output "security_group_arn" {
  description = "The ARN of the Security Group associated with the Glue connection"
  value       = module.security_group.arn
}

output "security_group_name" {
  description = "The name of the Security Group and associated with the Glue connection"
  value       = module.security_group.name
}
