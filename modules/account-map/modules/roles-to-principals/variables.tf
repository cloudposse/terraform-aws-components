variable "role_map" {
  type        = map(list(string))
  description = "Map of account:[role, role...]. Use `*` as role for entire account"
}

variable "permission_set_map" {
  type        = map(list(string))
  description = "Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets when accessed from specified accounts"
  default     = {}
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

## The overridable_* variables in this file provide Cloud Posse defaults.
## Because this module is used in bootstrapping Terraform, we do not configure
## these inputs in the normal way. Instead, to change the values, you should
## add a `variables_override.tf` file and change the default to the value you want.
variable "overridable_global_tenant_name" {
  type        = string
  description = "The tenant name used for organization-wide resources"
  default     = "core"
}

variable "overridable_global_environment_name" {
  type        = string
  description = "Global environment name"
  default     = "gbl"
}

variable "overridable_global_stage_name" {
  type        = string
  description = "The stage name for the organization management account (where the `account-map` state is stored)"
  default     = "root"
}
