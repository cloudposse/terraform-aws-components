locals {
  enabled                            = module.this.enabled
  create_sns_topic                   = local.enabled && var.create_sns_topic
  account_map                        = module.account_map.outputs.full_account_map
  central_resource_collector_account = local.account_map[var.central_resource_collector_account]
  organization_admin_account         = local.account_map[var.organization_admin_account]
  account_id                         = one(data.aws_caller_identity.this[*].account_id)
  is_global_collector_account        = local.account_id == local.central_resource_collector_account
  is_organization_admin_account      = local.account_id == local.organization_admin_account
  member_account_list                = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.account_id]
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

module "guardduty_primary" {
  count   = local.enabled && local.is_global_collector_account ? 1 : 0
  source  = "cloudposse/guardduty/aws"
  version = "0.5.0"

  finding_publishing_frequency              = var.finding_publishing_frequency
  create_sns_topic                          = var.create_sns_topic
  findings_notification_arn                 = var.findings_notification_arn
  subscribers                               = var.subscribers
  enable_cloudwatch                         = var.enable_cloudwatch
  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type
  s3_protection_enabled                     = var.s3_protection_enabled

  context = module.this.context
}

module "guardduty" {
  count   = local.enabled && !local.is_global_collector_account ? 1 : 0
  source  = "cloudposse/guardduty/aws"
  version = "0.5.0"

  s3_protection_enabled = var.s3_protection_enabled

  context = module.this.context
}

resource "awsutils_guardduty_organization_settings" "this" {
  count = local.enabled && var.admin_delegated && local.is_global_collector_account ? 1 : 0

  member_accounts = local.member_account_list
  detector_id     = module.guardduty_primary[0].guardduty_detector.id
}

resource "aws_guardduty_organization_configuration" "this" {
  count = local.enabled && var.admin_delegated && local.is_global_collector_account ? 1 : 0

  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = module.guardduty_primary[0].guardduty_detector.id
  depends_on                       = [module.guardduty_primary[0].guardduty_detector]

  datasources {
    s3_logs {
      auto_enable = var.s3_protection_enabled
    }
    kubernetes {
      audit_logs {
        enable = var.kubernetes_audit_logs_enabled
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.malware_protection_scan_ec2_ebs_volumes_enabled
        }
      }
    }
  }
}

resource "aws_guardduty_organization_admin_account" "this" {
  count = local.enabled && local.is_organization_admin_account ? 1 : 0

  admin_account_id = local.central_resource_collector_account
}
