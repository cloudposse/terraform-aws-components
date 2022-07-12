variable "region" {
  type        = string
  description = "AWS Region"
}

variable "roles" {
  description = "A map of roles to configure the accounts."
  type = map(object({
    enabled = bool

    denied_teams            = list(string)
    denied_permission_sets  = list(string)
    denied_role_arns        = list(string)
    max_session_duration    = number # in seconds 3600 <= max <= 43200 (12 hours)
    role_description        = string
    role_policy_arns        = list(string)
    aws_saml_login_enabled  = bool
    trusted_teams           = list(string)
    trusted_permission_sets = list(string)
    trusted_role_arns       = list(string)
  }))
}

variable "trusted_github_repos" {
  type        = map(list(string))
  description = <<-EOT
    Map where keys are role names (same keys as `roles`) and values are lists of
    GitHub repositories allowed to assume those roles. See `account-map/modules/github-assume-role-policy.mixin.tf`
    for specifics about repository designations.
    EOT
  default     = {}
}
