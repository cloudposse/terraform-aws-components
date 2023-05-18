variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_tenant" {
  type        = string
  default     = ""
  description = "(Optional) The tenant where the account_map component required by remote-state is deployed."
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = "The stage name for the Organization root (master) account"
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

variable "central_resource_collector_account" {
  description = "The name of the account that is the centralized aggregation account."
  type        = string
}

variable "admin_delegated" {
  type        = bool
  default     = true
  description = <<DOC
  A flag to indicate if the GuardDuty Admininstrator account has been designed from the root account.

  This component should be applied with this variable set to false, then the compliance-root component should be applied
  to designate the administrator account, then this component should be applied again with this variable set to true. 
  DOC
}