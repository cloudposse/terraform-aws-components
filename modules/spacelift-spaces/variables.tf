variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = "mgmt"
}

variable "okta_group_creation_enabled" {
  type        = bool
  description = "Whether or not to create Okta groups for each Spacelift Space."
  default     = false
}

variable "okta_group_prefix" {
  type        = string
  description = "A prefix to add to all managed Okta groups."
  default     = ""
}
