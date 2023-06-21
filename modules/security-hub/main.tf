locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map

  current_account_id                     = one(data.aws_caller_identity.this[*].account_id)
  member_account_id_list                 = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.current_account_id]
  org_delegated_administrator_account_id = local.account_map[var.delegated_administrator_account_name]
  org_management_account_id              = var.organization_management_account_name == null ? local.account_map[module.account_map.outputs.root_account_account_name] : local.account_map[var.organization_management_account_name]
  is_org_delegated_administrator_account = local.current_account_id == local.org_delegated_administrator_account_id
  is_org_management_account              = local.current_account_id == local.org_management_account_id
  is_finding_aggregation_region          = local.enabled && var.finding_aggregator_enabled && var.finding_aggregation_region == data.aws_region.this[0].name

  create_sns_topic         = local.enabled && var.create_sns_topic
  create_securityhub       = local.enabled && local.is_org_delegated_administrator_account && !var.admin_delegated
  create_org_delegation    = local.enabled && local.is_org_management_account
  create_org_configuration = local.enabled && local.is_org_delegated_administrator_account && var.admin_delegated
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

data "aws_region" "this" {
  count = local.enabled ? 1 : 0
}

# If we are running in the AWS Org Management account, delegate Security Hub to the Delegated Admininstrator account
# (usually the security account). We also need to turn on Security Hub in the Management account so that it can
# aggregate findings and be managed by the Delegated Admininstrator account.
resource "aws_securityhub_organization_admin_account" "this" {
  count = local.create_org_delegation ? 1 : 0

  admin_account_id = local.org_delegated_administrator_account_id
}

resource "aws_securityhub_account" "this" {
  count = local.create_org_delegation ? 1 : 0

  enable_default_standards = var.default_standards_enabled
}

# If we are running in the AWS Org designated administrator account, enable Security Hub and optionally enable standards
# and finding aggregation
module "security_hub" {
  count   = local.create_securityhub ? 1 : 0
  source  = "cloudposse/security-hub/aws"
  version = "0.10.0"


  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type
  create_sns_topic                          = local.create_sns_topic
  enable_default_standards                  = var.default_standards_enabled
  enabled_standards                         = var.enabled_standards
  finding_aggregator_enabled                = local.is_finding_aggregation_region
  finding_aggregator_linking_mode           = var.finding_aggregator_linking_mode
  finding_aggregator_regions                = var.finding_aggregator_regions
  imported_findings_notification_arn        = var.findings_notification_arn
  subscribers                               = var.subscribers

  context = module.this.context
}

# If we are running in the AWS Org designated administrator account with admin_delegated set to tru, set the AWS
# Organization-wide Security Hub configuration by configuring all other accounts to send their Security Hub findings to
# this account.
resource "awsutils_security_hub_organization_settings" "this" {
  count = local.create_org_configuration ? 1 : 0

  member_accounts = local.member_account_id_list
}

resource "aws_securityhub_organization_configuration" "this" {
  count = local.create_org_configuration ? 1 : 0

  auto_enable           = var.auto_enable_organization_members
  auto_enable_standards = var.default_standards_enabled ? "DEFAULT" : "NONE"
}
