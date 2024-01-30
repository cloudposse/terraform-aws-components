# The GitHub webhook can be created with this component, with another component (such as github-webhook), or manually.
# However, we need to define the value for the webhook secret now with the ArgoCD chart deployment. Store it in SSM for reference.
#
# We need to create the webhook with a separate component if we're deploying argocd-repos for multiple GitHub Organizations
locals {
  github_webhook_enabled = local.enabled && var.github_webhook_enabled
  create_github_webhook  = local.github_webhook_enabled && var.create_github_webhook

  webhook_github_secret = local.github_webhook_enabled ? try(random_password.webhook["github"].result, null) : ""
}

variable "github_webhook_enabled" {
  type        = bool
  default     = true
  description = "Enable GitHub webhook integration"
}

variable "create_github_webhook" {
  type        = bool
  default     = true
  description = "If enabled, create the GitHub webhook with the GitHub Terraform provider. Disable this setting if creating the webhook outside of this component"
}

variable "ssm_github_webhook" {
  type        = string
  description = "Format string of the SSM parameter path to which the webhook will be written to (%s will be replaced with the GitHub organization and repo names respectively)"
  default     = "/argocd/github/webhook"
}

resource "random_password" "webhook" {
  for_each = toset(local.github_webhook_enabled ? ["github"] : [])

  # min 16, max 128
  length  = 128
  special = true

  min_upper   = 3
  min_lower   = 3
  min_numeric = 3
  min_special = 3
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.11.0"

  parameter_write = [
    {
      name        = var.ssm_github_webhook
      value       = local.webhook_github_secret
      type        = "SecureString"
      overwrite   = true
      description = "GitHub webhook secret value used for ArgoCD"
    }
  ]

  context = module.this.context
}

resource "github_repository_webhook" "default" {
  for_each   = local.create_github_webhook ? local.argocd_repositories : {}
  repository = each.value.repository

  configuration {
    url          = format("%s/api/webhook", local.url)
    content_type = "json"
    secret       = local.webhook_github_secret
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
