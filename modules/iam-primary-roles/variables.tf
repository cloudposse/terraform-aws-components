variable "iam_role_max_session_duration" {
  type        = number
  default     = 43200
  description = "The maximum session duration (in seconds) that you want to set for the IAM roles. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "assume_role_restricted" {
  type    = bool
  default = true
  # Set false only during cold start, when roles do not yet exist to be granted permissions
  description = "Set true to restrict (via trust policy) who can assume into a role"
}

variable "primary_account_id" {
  description = "Primary authentication account id used as the source for assume role"
  type        = string
}

variable "delegated_roles_config" {
  description = "A roles map to configure the accounts."
  type = map(object({
    role_policy_arns      = list(string)
    role_description      = string
    sso_login_enabled     = bool
    trusted_primary_roles = list(string)
  }))
}

variable "primary_roles_config" {
  description = "A roles map to configure the accounts."
  type = map(object({
    role_policy_arns      = list(string)
    role_description      = string
    sso_login_enabled     = bool
    trusted_primary_roles = list(string)
  }))
}

variable "cicd_sa_roles" {
  description = "A list of Role ARNs that cicd runners may start with. Will be allowed to assume xxx-gbl-identity-cicd"
  type        = list(string)
  default     = []
}

variable "sso_environment_name" {
  type        = string
  description = "The name of the environment where SSO is provisioned"
  default     = "gbl"
}

variable "sso_stage_name" {
  type        = string
  description = "The name of the stage where SSO is provisioned"
  default     = "identity"
}

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

variable "root_account_stage_name" {
  type        = string
  description = "The name of the stage for the root account"
  default     = "root"
}

variable "identity_account_stage_name" {
  type        = string
  description = "The name of the stage for the identity account"
  default     = "identity"
}

variable "audit_account_stage_name" {
  type        = string
  description = "The name of the stage for the audit account"
  default     = "audit"
}
