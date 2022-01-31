variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
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

variable "root_account_tenant_name" {
  type        = string
  description = <<-EOT
  The tenant name for the root account.

  If the `tenant` label is not used, set this to `null`.
  EOT
  default     = "mgmt"
}

variable "stack_config_local_path" {
  description = <<-EOT
  An override for the `stack_config_local_path` when invoking the `account-map` module.

  This is useful when invoking this module from another repository, which may not have a `stacks` directory.

  Leave this as `null` when not performing such an invocation.
  EOT
  default     = "../../../stacks"
}