variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "global_tenant_name" {
  type        = string
  description = "Global tenant name"
  default     = null
}

variable "global_environment_name" {
  type        = string
  description = "Global environment name"
  default     = "gbl"
}

variable "root_account_stage_name" {
  type        = string
  description = "The stage name for the root account"
  default     = "root"
}
