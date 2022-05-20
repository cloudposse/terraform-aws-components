variable "region" {
  type        = string
  description = "AWS Region"
}

variable "roles" {
  description = "A roles map to configure the accounts."
  type = map(object({
    enabled = bool

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
