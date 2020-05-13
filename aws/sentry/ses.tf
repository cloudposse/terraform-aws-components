variable "ses_enabled" {
  type        = bool
  default     = false
  description = "Set true to enable SES for sending emails."
}

variable "ses_domain" {
  description = "The domain to create the SES identity for."
  type        = string
}

variable "ses_zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create Route53 DNS records used for verification"
  default     = ""
}

variable "ses_verify_domain" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for domain verification."
  default     = null
}

variable "ses_verify_dkim" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for DKIM verification."
  default     = null
}

module "ses" {
  source        = "git::https://github.com/cloudposse/terraform-aws-ses.git?ref=ses-module"
  namespace     = var.namespace
  name          = "sentry-ses"
  stage         = var.stage
  enabled       = var.ses_enabled
  domain        = var.ses_domain
  zone_id       = var.ses_zone_id
  verify_dkim   = var.ses_verify_dkim
  verify_domain = var.ses_verify_domain
}

output "access_key_id" {
  value       = module.ses.access_key_id
  description = "The access key ID"
}

output "secret_access_key" {
  sensitive   = true
  value       = module.ses.secret_access_key
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "user_name" {
  value       = module.ses.user_name
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = module.ses.user_arn
  description = "The ARN assigned by AWS for this user"
}

output "user_unique_id" {
  value       = module.ses.user_unique_id
  description = "The unique ID assigned by AWS"
}

