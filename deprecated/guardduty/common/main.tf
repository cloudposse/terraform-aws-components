locals {
  enabled                            = module.this.enabled
  create_sns_topic                   = local.enabled && var.create_sns_topic
  account_map                        = module.account_map.outputs.full_account_map
  central_resource_collector_account = local.account_map[var.central_resource_collector_account]
  account_id                         = one(data.aws_caller_identity.this[*].account_id)
  is_global_collector_account        = local.account_id == local.central_resource_collector_account
  member_account_list                = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.account_id]
}

module "guardduty" {
  count   = local.enabled && local.is_global_collector_account ? 1 : 0
  source  = "cloudposse/guardduty/aws"
  version = "0.5.0"

  finding_publishing_frequency              = var.finding_publishing_frequency
  create_sns_topic                          = var.create_sns_topic
  findings_notification_arn                 = var.findings_notification_arn
  subscribers                               = var.subscribers
  enable_cloudwatch                         = var.enable_cloudwatch
  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type

  context = module.this.context
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

resource "awsutils_guardduty_organization_settings" "this" {
  count = local.enabled && var.admin_delegated && local.is_global_collector_account ? 1 : 0

  member_accounts = local.member_account_list
  detector_id     = module.guardduty[0].guardduty_detector.id
}
