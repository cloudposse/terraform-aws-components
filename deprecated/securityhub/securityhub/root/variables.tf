variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_tenant" {
  type        = string
  default     = ""
  description = "The tenant where the `account_map` component required by remote-state is deployed"
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = "The stage name for the Organization root (management) account"
}

variable "global_environment" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "administrator_account" {
  description = "The name of the account that is the Security Hub administrator account"
  type        = string
  default     = null
}

variable "enable_default_standards" {
  description = "Flag to indicate whether default standards should be enabled"
  type        = bool
  default     = true
}

variable "enabled_standards" {
  description = <<DOC
  A list of standards to enable in the account.

  For example:
  - standards/aws-foundational-security-best-practices/v/1.0.0
  - ruleset/cis-aws-foundations-benchmark/v/1.2.0
  - standards/pci-dss/v/3.2.1
  - standards/cis-aws-foundations-benchmark/v/1.4.0
  DOC
  type        = set(string)
  default     = []
}
