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
  description = "The value to use as the GitHub webhook secret."
  default     = ""
}

variable "ssm_github_webhook" {
  type        = string
  description = "Format string of the SSM parameter path where the webhook will be pulled from. Only used if `var.webhook_github_secret` is not given."
  default     = "/github/webhook"
}
