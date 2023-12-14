variable "region" {
  type        = string
  description = "AWS region"
}

variable "application_provider_arn" {
  type        = string
  default     = "arn:aws:sso::aws:applicationProvider/custom-saml"
  description = "AWS SSO Application Provider ARN"
}

variable "description" {
  type        = string
  default     = "AWS EC2 Client VPN"
  description = "Description of the AWS SSO Application"
}

variable "portal_options" {
  type = map(object({
    sign_in_options = optional(map(object({
      application_url = optional(string)
      origin          = optional(string)
    })))
    visibility = optional(string)
  }))
  default     = {}
  description = "Portal options for the AWS SSO Application"
}
