variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ses_verify_domain" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for domain verification."
  default     = true
}

variable "ses_verify_dkim" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for DKIM verification."
  default     = true
}

variable "domain_template" {
  type        = string
  description = "The `format()` string to use to generate the base domain name for sending and receiving email with Amazon SES, `format(var.domain_template, var.tenant, var.environment, var.stage)"
}
