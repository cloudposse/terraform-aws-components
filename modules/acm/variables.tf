variable "region" {
  type        = string
  description = "AWS Region"
}

variable "domain_name" {
  type        = string
  description = "Root domain name"
  default     = ""
}

variable "domain_name_prefix" {
  type        = string
  description = "Root domain name prefix to use with DNS delegated remote state"
  default     = ""
}

variable "zone_name" {
  type        = string
  default     = ""
  description = <<-EOT
    Name of the zone in which to place the DNS validation records to validate the certificate.
    Typically a domain name. Default of `""` actually defaults to `domain_name`.
    EOT
}

variable "process_domain_validation_options" {
  type        = bool
  default     = false
  description = "Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation"
}

variable "validation_method" {
  type        = string
  default     = "DNS"
  description = "Method to use for validation, DNS or EMAIL"
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "A list of domains that should be SANs in the issued certificate"
}

variable "subject_alternative_names_prefixes" {
  type        = list(string)
  default     = []
  description = "A list of domain prefixes to use with DNS delegated remote state that should be SANs in the issued certificate"
}

variable "dns_private_zone_enabled" {
  type        = bool
  description = "Whether to set the zone to public or private"
  default     = false
}

variable "certificate_authority_enabled" {
  type        = bool
  description = "Whether to use the certificate authority or not"
  default     = false
}

variable "certificate_authority_component_name" {
  type        = string
  default     = null
  description = "Use this component name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE"
}

variable "certificate_authority_stage_name" {
  type        = string
  default     = null
  description = "Use this stage name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE"
}

variable "certificate_authority_environment_name" {
  type        = string
  default     = null
  description = "Use this environment name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE"
}

variable "certificate_authority_component_key" {
  type        = string
  default     = null
  description = "Use this component key e.g. `root` or `mgmt` to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE"
}

variable "dns_delegated_stage_name" {
  type        = string
  default     = null
  description = "Use this stage name to read from the remote state to get the dns_delegated zone ID"
}

variable "dns_delegated_environment_name" {
  type        = string
  default     = "gbl"
  description = "Use this environment name to read from the remote state to get the dns_delegated zone ID"
}

variable "dns_delegated_component_name" {
  type        = string
  default     = "dns-delegated"
  description = "Use this component name to read from the remote state to get the dns_delegated zone ID"
}
