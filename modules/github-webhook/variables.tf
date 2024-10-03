variable "region" {
  description = "AWS Region."
  type        = string
}

variable "github_repository" {
  type        = string
  description = "The name of the GitHub repository where the webhook will be created"
}

variable "github_organization" {
  type        = string
  description = "The name of the GitHub Organization where the repository lives"
}

variable "webhook_url" {
  type        = string
  description = "The URL for the webhook"
}

variable "webhook_github_secret" {
  type        = string
  description = "The value to use as the GitHub webhook secret. Set both `var.ssm_github_webhook_enabled` and `var.remote_state_github_webhook_enabled` to `false` in order to use this value"
  default     = ""
}

variable "ssm_github_webhook_enabled" {
  type        = bool
  description = "If `true`, pull the GitHub Webhook value from AWS SSM Parameter Store using `var.ssm_github_webhook`"
  default     = false
}

variable "ssm_github_webhook" {
  type        = string
  description = "Format string of the SSM parameter path where the webhook will be pulled from. Only used if `var.webhook_github_secret` is not given."
  default     = "/github/webhook"
}

variable "remote_state_github_webhook_enabled" {
  type        = bool
  description = "If `true`, pull the GitHub Webhook value from remote-state"
  default     = true
}

variable "remote_state_component_name" {
  type        = string
  description = "If fetching the Github Webhook value from remote-state, set this to the source component name. For example, `eks/argocd`."
  default     = ""
}
