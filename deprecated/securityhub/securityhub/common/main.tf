locals {
  enabled                            = module.this.enabled
  account_map                        = module.account_map.outputs.full_account_map
  central_resource_collector_account = local.account_map[var.central_resource_collector_account]
  account_id                         = one(data.aws_caller_identity.this[*].account_id)
  region_name                        = one(data.aws_region.this[*].name)
  is_global_collector_account        = local.central_resource_collector_account == local.account_id
  is_collector_region                = local.region_name == var.central_resource_collector_region
  member_account_list                = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.account_id]
  enabled_standards_arns = toset([
    for standard in var.enabled_standards :
    format("arn:%s:securityhub:%s::%s", one(data.aws_partition.this[*].partition), length(regexall("ruleset", standard)) == 0 ? one(data.aws_region.this[*].name) : "", standard)
  ])
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

data "aws_region" "this" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "this" {
  count = local.enabled ? 1 : 0
}

module "security_hub" {
  count   = local.enabled && local.is_global_collector_account ? 1 : 0
  source  = "cloudposse/security-hub/aws"
  version = "0.10.0"

  create_sns_topic                = var.create_sns_topic
  enabled_standards               = var.enabled_standards
  finding_aggregator_enabled      = local.is_collector_region && var.finding_aggregator_enabled
  finding_aggregator_linking_mode = var.finding_aggregator_linking_mode
  finding_aggregator_regions      = var.finding_aggregator_regions
  enable_default_standards        = var.enable_default_standards

  context = module.this.context
}

resource "aws_securityhub_account" "this" {
  count = local.enabled && !local.is_global_collector_account ? 1 : 0

  enable_default_standards = var.enable_default_standards
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each      = local.enabled && !local.is_global_collector_account ? local.enabled_standards_arns : []
  depends_on    = [aws_securityhub_account.this]
  standards_arn = each.key
}

resource "awsutils_security_hub_organization_settings" "this" {
  count = local.enabled && local.is_global_collector_account && var.admin_delegated ? 1 : 0

  member_accounts          = local.member_account_list
  auto_enable_new_accounts = true
}
