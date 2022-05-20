variable "iam_role_max_session_duration" {
  type        = number
  default     = 43200
  description = <<-EOT
    The maximum session duration (in seconds) that you want to set for the IAM roles.
    This setting can have a value from 3600 (1 hour) to 43200 (12 hours).
    EOT
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

variable "default_assume_role_enabled" {
  type    = bool
  default = false
  # Set to true for AWS SSO
  description = "Set true to allow unknown roles to assume this role (e.g. for AWS SSO)"
}

variable "primary_account_id" {
  description = "Primary authentication account ID used as the source for assume role"
  type        = string
  default     = ""
}

variable "primary_account_stage_name" {
  description = "Primary authentication account name used as the source for assume role"
  type        = string
  default     = "identity"
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

variable "spacelift_roles_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to allow designated Spacelift roles to assume the Identity Ops role (and pull Spacelift roles from the remote state of the `spacelift-worker-pool` component)"
}

variable "spacelift_worker_pool_stage_name" {
  type        = string
  description = "The name of the stage where spacelift_worker_pool is provisioned"
  default     = "auto"
}

variable "spacelift_worker_pool_environment_name" {
  type        = string
  description = "The name of the stage where spacelift_worker_pool is provisioned"
  default     = "ue2"
}

variable "spacelift_roles" {
  description = "A list of Spacelift role ARNs. Will be allowed to assume xxx-gbl-identity-ops"
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
