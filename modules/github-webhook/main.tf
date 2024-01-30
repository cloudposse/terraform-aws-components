locals {
  enabled = module.this.enabled

  fetch_github_webhook = local.enabled && !(length(var.webhook_github_secret) > 0)

  # If fetching webhook, get the value from SSM
  # Else, get the value given by var.webhook_github_secret
  webhook_github_secret = local.fetch_github_webhook ? try(data.aws_ssm_parameter.webhook[0].value, null) : var.webhook_github_secret
}

data "aws_ssm_parameter" "webhook" {
  count = local.fetch_github_webhook ? 1 : 0

  name            = var.ssm_github_webhook
  with_decryption = true
}

resource "github_repository_webhook" "default" {
  count = local.fetch_github_webhook ? 1 : 0

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
