output "smtp_password" {
  sensitive   = true
  value       = module.ses.ses_smtp_password
  description = "The SMTP password. This will be written to the state file in plain text."
}

output "smtp_user" {
  value       = module.ses.access_key_id
  description = "Access key ID of the IAM user with permission to send emails from SES domain"
}

output "user_name" {
  value       = module.ses.user_name
  description = "Normalized name of the IAM user with permission to send emails from SES domain"
}

output "user_unique_id" {
  value       = module.ses.user_unique_id
  description = "The unique ID of the IAM user with permission to send emails from SES domain"
}

output "user_arn" {
  value       = module.ses.user_arn
  description = "The ARN the IAM user with permission to send emails from SES domain"
}
