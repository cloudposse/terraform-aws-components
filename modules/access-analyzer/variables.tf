variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_tenant" {
  type        = string
  description = "The tenant where the `account_map` component required by remote-state is deployed"
}

variable "delegated_administrator_account_name" {
  type        = string
  description = "The name of the account that is the AWS Organization Delegated Administrator account"
}

variable "global_environment" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "organization_management_account_name" {
  type        = string
  default     = null
  description = "The name of the AWS Organization management account"
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = <<-DOC
  The stage name for the Organization root (management) account. This is used to lookup account IDs from account names
  using the `account-map` component.
  DOC
}

variable "accessanalyzer_organization_enabled" {
  type        = bool
  description = "Flag to enable the Organization Access Analyzer"
}

variable "accessanalyzer_organization_unused_access_enabled" {
  type        = bool
  description = "Flag to enable the Organization unused access Access Analyzer"
}

variable "unused_access_age" {
  type        = number
  description = "The specified access age in days for which to generate findings for unused access"
  default     = 30
}

variable "organizations_delegated_administrator_enabled" {
  type        = bool
  description = "Flag to enable the Organization delegated administrator"
}

variable "accessanalyzer_service_principal" {
  type        = string
  description = "The Access Analyzer service principal for which you want to make the member account a delegated administrator"
  default     = "access-analyzer.amazonaws.com"
}
