variable "region" {
  description = "AWS Region"
  type        = string
}

variable "delegated_roles_config" {
  description = "A roles map to configure the accounts."
  type = map(object({
    denied_permission_sets  = list(string)
    denied_primary_roles    = list(string)
    denied_role_arns        = list(string)
    max_session_duration    = number # in seconds 3600 <= max <= 43200 (12 hours)
    role_description        = string
    role_policy_arns        = list(string)
    sso_login_enabled       = bool
    trusted_permission_sets = list(string)
    trusted_primary_roles   = list(string)
    trusted_role_arns       = list(string)
  }))
}

variable "primary_roles_config" {
  description = "A roles map to configure the accounts."
  type = map(object({
    denied_permission_sets  = list(string)
    denied_primary_roles    = list(string)
    denied_role_arns        = list(string)
    max_session_duration    = number # in seconds 3600 <= max <= 43200 (12 hours)
    role_description        = string
    role_policy_arns        = list(string)
    sso_login_enabled       = bool
    trusted_permission_sets = list(string)
    trusted_primary_roles   = list(string)
    trusted_role_arns       = list(string)
  }))
}

variable "sso_environment_name" {
  description = "The name of the environment where SSO is provisioned"
  type        = string
  default     = "gbl"
}

variable "sso_stage_name" {
  description = "The name of the stage where SSO is provisioned"
  type        = string
  default     = "identity"
}

variable "account_map_environment_name" {
  description = "The name of the environment where `account_map` is provisioned"
  type        = string
  default     = "gbl"
}

variable "account_map_stage_name" {
  description = "The name of the stage where `account_map` is provisioned"
  type        = string
  default     = "root"
}

variable "identity_account_stage_name" {
  description = "The name of the stage for the identity account"
  type        = string
  default     = "identity"
}
