locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map
}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.3.0"

  context = module.this.context
}

resource "aws_guardduty_organization_admin_account" "this" {
  count = local.enabled && var.administrator_account != null && var.administrator_account != "" ? 1 : 0

  admin_account_id = local.account_map[var.administrator_account]
}

resource "aws_guardduty_detector" "this" {
  count = local.enabled && var.administrator_account != null && var.administrator_account != "" ? 1 : 0

  enable = true

  datasources {
    s3_logs {
      enable = true
    }
  }
}
