module "budgets" {
  source  = "cloudposse/budgets/aws"
  version = "0.2.1"
  enabled = module.this.enabled && var.budgets_enabled

  budgets = var.budgets

  notifications_enabled = var.budgets_notifications_enabled
  encryption_enabled    = true

  slack_webhook_url = var.budgets_slack_webhook_url
  slack_channel     = var.budgets_slack_channel
  slack_username    = var.budgets_slack_username

  context = module.this.context
}
