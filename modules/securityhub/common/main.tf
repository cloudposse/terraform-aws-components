locals {
  enabled                            = var.enabled
  account_map                        = module.account_map.outputs.full_account_map
  central_resource_collector_account = local.account_map[var.central_resource_collector_account]
  account_id                         = one(data.aws_caller_identity.this[*].account_id)
  is_global_collector_account        = local.central_resource_collector_account == local.account_id
  member_account_list                = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.account_id]
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

module "security_hub" {
  count   = local.enabled && local.is_global_collector_account ? 1 : 0
  source  = "cloudposse/security-hub/aws"
  version = "0.9.0"

  create_sns_topic  = var.create_sns_topic
  enabled_standards = var.enabled_standards

  context = module.this.context
}

resource "awsutils_security_hub_organization_settings" "this" {
  count = local.enabled && local.is_global_collector_account && var.admin_delegated ? 1 : 0

  member_accounts          = local.member_account_list
  auto_enable_new_accounts = true
}