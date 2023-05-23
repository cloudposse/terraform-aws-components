locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map
}

resource "aws_securityhub_organization_admin_account" "this" {
  count = local.enabled && var.administrator_account != null && var.administrator_account != "" ? 1 : 0

  admin_account_id = local.account_map[var.administrator_account]
}

# Enable Security Hub for the organization
resource "aws_securityhub_account" "this" {
  count = local.enabled && var.administrator_account != null && var.administrator_account != "" ? 1 : 0

  depends_on = [
    aws_securityhub_organization_admin_account.this
  ]
}
