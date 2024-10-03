output "role_name" {
  value       = module.iam_role.name
  description = "The name of the Glue role"
}

output "role_id" {
  value       = module.iam_role.id
  description = "The ID of the Glue role"
}

output "role_arn" {
  value       = module.iam_role.arn
  description = "The ARN of the Glue role"
}
