output "snowflake_account" {
  value       = var.snowflake_account
  description = "The Snowflake account ID."
}

output "snowflake_region" {
  value       = var.snowflake_account_region
  description = "The AWS Region with the Snowflake account."
}

output "snowflake_terraform_role" {
  value       = local.snowflake_terraform_role
  description = "The name of the role given to the Terraform service user."
}

output "ssm_path_terraform_user_name" {
  value       = local.ssm_path_terraform_user_name
  description = "The path to the SSM parameter for the Terraform user name."
}

output "ssm_path_terraform_user_private_key" {
  value       = local.ssm_path_terraform_user_private_key
  description = "The path to the SSM parameter for the Terraform user private key."
}
