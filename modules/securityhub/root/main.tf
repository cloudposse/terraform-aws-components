locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map
  enabled_standards_arns = toset([
    for standard in var.enabled_standards :
    format("arn:%s:securityhub:%s::%s", one(data.aws_partition.this[*].partition), length(regexall("ruleset", standard)) == 0 ? one(data.aws_region.this[*].name) : "", standard)
  ])
}

data "aws_partition" "this" {
  count = local.enabled ? 1 : 0
}

data "aws_region" "this" {
  count = local.enabled ? 1 : 0
}

resource "aws_securityhub_organization_admin_account" "this" {
  count = local.enabled && var.administrator_account != null && var.administrator_account != "" ? 1 : 0

  admin_account_id = local.account_map[var.administrator_account]
}

resource "aws_securityhub_account" "this" {
  count = local.enabled ? 1 : 0

  enable_default_standards = var.enable_default_standards

  depends_on = [
    aws_securityhub_organization_admin_account.this
  ]
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each      = local.enabled ? local.enabled_standards_arns : []
  depends_on    = [aws_securityhub_account.this]
  standards_arn = each.key
}
