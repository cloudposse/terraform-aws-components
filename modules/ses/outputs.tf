output "smtp_user" {
  value       = module.ses.access_key_id
  description = "The SMTP user which is access key ID."
}

output "smtp_password" {
  sensitive   = true
  value       = module.ses.ses_smtp_password
  description = "The SMTP password. This will be written to the state file in plain text."
}

output "user_arn" {
  value       = module.ses.user_arn
  description = "The ARN assigned by AWS for this user."
}

output "user_name" {
  value       = module.ses.user_name
  description = "Normalized IAM user name."
}

output "user_unique_id" {
  value       = module.ses.user_unique_id
  description = "The unique ID assigned by AWS."
}

