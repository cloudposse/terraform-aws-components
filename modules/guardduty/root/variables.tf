variable "region" {
  type        = string
  description = "AWS Region"
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

variable "administrator_account" {
  description = "The name of the account that is the GuardDuty adminstrator account."
  type        = string
  default     = null
}
