locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map

  current_account_id                     = one(data.aws_caller_identity.this[*].account_id)
  member_account_id_list                 = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.current_account_id]
  org_delegated_administrator_account_id = local.account_map[var.delegated_administrator_account_name]
  org_management_account_id              = var.organization_management_account_name == null ? local.account_map[module.account_map.outputs.root_account_account_name] : local.account_map[var.organization_management_account_name]
  is_org_delegated_administrator_account = local.current_account_id == local.org_delegated_administrator_account_id
  is_org_management_account              = local.current_account_id == local.org_management_account_id

  create_sns_topic           = local.enabled && var.create_sns_topic
  create_guardduty_collector = local.enabled && ((local.is_org_delegated_administrator_account && !var.admin_delegated) || local.is_org_management_account)
  create_org_delegation      = local.enabled && local.is_org_management_account
  create_org_configuration   = local.enabled && local.is_org_delegated_administrator_account && var.admin_delegated

  guardduty_features = {
    "s3_data_events" = {
      name                     = "S3_DATA_EVENTS"
      additional_configuration = []
      enable                   = var.s3_protection_enabled
    },
    "eks_audit_logs" = {
      name                     = "EKS_AUDIT_LOGS"
      additional_configuration = []
      enable                   = var.kubernetes_audit_logs_enabled
    },
    "ebs_malware_protection" = {
      name                     = "EBS_MALWARE_PROTECTION"
      additional_configuration = []
      enable                   = var.malware_protection_scan_ec2_ebs_volumes_enabled
    },
    "rds_login_events" = {
      name                     = "RDS_LOGIN_EVENTS"
      additional_configuration = []
      enable                   = var.rds_login_events_enabled
    },
    "eks_runtime_monitoring" = {
      name                     = "EKS_RUNTIME_MONITORING"
      additional_configuration = ["EKS_ADDON_MANAGEMENT"]
      enable                   = var.eks_runtime_monitoring_enabled
    },
    "lambda_network_logs" = {
      name                     = "LAMBDA_NETWORK_LOGS"
      additional_configuration = []
      enable                   = var.lambda_network_logs_enabled
    },
    "runtime_monitoring" = {
      name                     = "RUNTIME_MONITORING"
      additional_configuration = ["EKS_ADDON_MANAGEMENT", "ECS_FARGATE_AGENT_MANAGEMENT", "EC2_AGENT_MANAGEMENT"]
      enable                   = var.runtime_monitoring_enabled
    }
  }
  enabled_features = {
    for key, feature in local.guardduty_features : key => feature if feature.enable
  }
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

# If we are are in the AWS Org management account, delegate GuardDuty to the org administrator account
# (usually the security account)
resource "aws_guardduty_organization_admin_account" "this" {
  count = local.create_org_delegation ? 1 : 0

  admin_account_id = local.org_delegated_administrator_account_id
}

# If we are are in the AWS Org designated administrator account, enable the GuardDuty detector and optionally create an
# SNS topic for notifications and CloudWatch event rules for findings
module "guardduty" {
  count   = local.create_guardduty_collector ? 1 : 0
  source  = "cloudposse/guardduty/aws"
  version = "0.5.0"

  finding_publishing_frequency              = var.finding_publishing_frequency
  create_sns_topic                          = local.create_sns_topic
  findings_notification_arn                 = var.findings_notification_arn
  subscribers                               = var.subscribers
  enable_cloudwatch                         = var.cloudwatch_enabled
  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type
  s3_protection_enabled                     = var.s3_protection_enabled

  context = module.this.context
}

# If we are are in the AWS Org designated administrator account, set the AWS Org-wide GuardDuty configuration by
# configuring all other accounts to send their GuardDuty findings to the detector in this account.
#
# This also configures the various Data Sources.
resource "awsutils_guardduty_organization_settings" "this" {
  count = local.create_org_configuration ? 1 : 0

  member_accounts = local.member_account_id_list
  detector_id     = module.guardduty_delegated_detector[0].outputs.guardduty_detector_id
}

resource "aws_guardduty_organization_configuration" "this" {
  count = local.create_org_configuration ? 1 : 0

  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = module.guardduty_delegated_detector[0].outputs.guardduty_detector_id
}

resource "aws_guardduty_organization_configuration_feature" "this" {
  for_each = local.create_org_configuration ? {
    for key, value in local.guardduty_features :
  key => value if value.enable == true } : {}

  name        = each.value.name
  auto_enable = var.auto_enable_guardduty_organization_features
  detector_id = module.guardduty_delegated_detector[0].outputs.guardduty_detector_id

  dynamic "additional_configuration" {
    for_each = each.value.additional_configuration != null ? toset(each.value.additional_configuration) : []
    content {
      auto_enable = var.auto_enable_guardduty_organization_features_additional_configurations
      name        = additional_configuration.value
    }
  }
}

resource "aws_guardduty_detector_feature" "this" {
  for_each = { for k, v in var.detector_features : k => v if local.create_org_configuration }

  detector_id = module.guardduty_delegated_detector[0].outputs.guardduty_detector_id
  name        = each.value.feature_name
  status      = each.value.status

  dynamic "additional_configuration" {
    for_each = each.value.additional_configuration != null ? [each.value.additional_configuration] : []
    content {
      name   = additional_configuration.value.addon_name
      status = additional_configuration.value.status
    }
  }
}
