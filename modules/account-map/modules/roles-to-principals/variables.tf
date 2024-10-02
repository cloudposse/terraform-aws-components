variable "role_map" {
  type        = map(list(string))
  description = "Map of account:[role, role...]. Use `*` as role for entire account"
  default     = {}
}

variable "permission_set_map" {
  type        = map(list(string))
  description = "Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets when accessed from specified accounts"
  default     = {}
}

variable "teams" {
  type        = list(string)
  description = "List of team names to translate to AWS SSO PermissionSet names"
  default     = []
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

variable "overridable_team_permission_set_name_pattern" {
  type        = string
  description = "The pattern used to generate the AWS SSO PermissionSet name for each team"
  default     = "Identity%sTeamAccess"
}

variable "overridable_team_permission_sets_enabled" {
  type        = bool
  description = <<-EOT
    When true, any roles (teams or team-roles) in the identity account references in `role_map`
    will cause corresponding AWS SSO PermissionSets to be included in the `permission_set_arn_like` output.
    This has the effect of treating those PermissionSets as if they were teams.
    The main reason to set this `false` is if IAM trust policies are exceeding size limits and you are not using AWS SSO.
    EOT
  default     = true
}
