locals {
  enabled = module.this.enabled

  remote_state_github_webhook_enabled = local.enabled && var.remote_state_github_webhook_enabled
  ssm_github_webhook_enabled          = local.enabled && var.ssm_github_webhook_enabled

  # If remote_state_github_webhook_enabled, get the value from remote-state
  # Else if ssm_github_webhook_enabled, get the value from SSM
  # Else, get the value given by var.webhook_github_secret
  webhook_github_secret = local.remote_state_github_webhook_enabled ? module.source[0].outputs.github_webhook_value : (local.ssm_github_webhook_enabled ? try(data.aws_ssm_parameter.webhook[0].value, null) : var.webhook_github_secret)
}

data "aws_ssm_parameter" "webhook" {
  count = local.ssm_github_webhook_enabled ? 1 : 0

  name            = var.ssm_github_webhook
  with_decryption = true
}

resource "github_repository_webhook" "default" {
  repository = var.github_repository

  configuration {
    url          = var.webhook_url
    content_type = "json"
    secret       = local.webhook_github_secret
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
