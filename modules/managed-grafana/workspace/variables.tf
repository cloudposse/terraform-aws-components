variable "region" {
  type        = string
  description = "AWS Region"
}

variable "sso_role_associations" {
  type = list(object({
    role      = string
    group_ids = list(string)
  }))
  description = "A list of role to group ID list associations for granting Amazon Grafana access"
  default     = []
}

variable "prometheus_policy_enabled" {
  type        = bool
  description = "Set this to `true` to allow this Grafana workspace to access Amazon Managed Prometheus in this account"
  default     = false
}

variable "prometheus_source_accounts" {
  type = list(object({
    component   = optional(string, "managed-prometheus/workspace")
    stage       = string
    tenant      = optional(string, "")
    environment = optional(string, "")
  }))
  description = "A list of objects that describe an account where Amazon Managed Prometheus is deployed. This component grants this Grafana IAM role permission to assume the Prometheus access role in that target account. Use this for cross-account access"
  default     = []
}


variable "private_network_access_enabled" {
  type        = bool
  description = "If set to `true`, enable the VPC Configuration to allow this workspace to access the private network using outputs from the vpc component"
  default     = false
}
