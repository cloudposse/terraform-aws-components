locals {
  enabled                            = module.this.enabled
  account_map                        = module.account_map.outputs.full_account_map
  central_logging_account            = local.account_map[var.central_logging_account]
  central_resource_collector_account = local.account_map[var.central_resource_collector_account]
  region_name                        = join("", data.aws_region.this[*].name)
  account_id                         = join("", data.aws_caller_identity.this[*].account_id)
  partition                          = join("", data.aws_partition.this[*].partition)
  mfa_control_arn                    = "arn:${local.partition}:securityhub:${local.region_name}:${local.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/1.14"
  disabled_controls                  = local.enabled && local.is_global_collector_account ? toset([for c in module.control_disablements[0].controls : c if c != local.mfa_control_arn]) : toset([])
  is_global_collector_account        = local.central_resource_collector_account == local.account_id
  is_global_collector_region         = local.region_name == var.global_resource_collector_region
  opsgenie_integration_enabled       = local.enabled && local.is_global_collector_account && var.opsgenie_sns_topic_subscription_enabled
  member_account_list                = [for a in keys(local.account_map) : (local.account_map[a]) if local.account_map[a] != local.account_id]
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
  version = "0.9.0"

  create_sns_topic  = var.create_sns_topic
  enabled_standards = var.enabled_standards
  subscribers = local.opsgenie_integration_enabled ? {
    opsgenie = {
      protocol               = "https"
      endpoint               = data.aws_ssm_parameter.opsgenie_integration_uri[0].value
      endpoint_auto_confirms = true
      raw_message_delivery   = false
    }
  } : {}

  context = module.this.context
}

resource "awsutils_security_hub_organization_settings" "this" {
  count = local.enabled && local.is_global_collector_account && var.admin_delegated ? 1 : 0

  member_accounts          = local.member_account_list
  auto_enable_new_accounts = true
}

#-----------------------------------------------------------------------------------------------------------------------
# DISABLE NON-RELEVANT CONTROLS
#-----------------------------------------------------------------------------------------------------------------------

module "control_disablements" {
  count   = local.enabled && local.is_global_collector_account ? 1 : 0
  source  = "cloudposse/security-hub/aws//modules/control-disablements"
  version = "0.9.0"

  global_resource_collector_region = var.global_resource_collector_region
  central_logging_account          = local.central_logging_account
}

resource "awsutils_security_hub_control_disablement" "global" {
  for_each    = local.disabled_controls
  control_arn = each.key
  reason      = "Global and CloudTrail resources are not collected in this account/region"

  depends_on = [
    module.security_hub
  ]
}

resource "awsutils_security_hub_control_disablement" "hardware_mfa_cis" {
  count       = local.enabled && local.is_global_collector_region ? 1 : 0
  control_arn = "arn:${local.partition}:securityhub:${local.region_name}:${local.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/1.14"
  reason      = "Virtual MFA tokens via 1Password are being used in favor of hardware MFA tokens"

  depends_on = [
    module.security_hub
  ]
}

resource "awsutils_security_hub_control_disablement" "hardware_mfa_foundational" {
  count       = local.enabled && local.is_global_collector_region ? 1 : 0
  control_arn = "arn:${local.partition}:securityhub:${local.region_name}:${local.account_id}:control/aws-foundational-security-best-practices/v/1.0.0/IAM.6"
  reason      = "Virtual MFA tokens via 1Password are being used in favor of hardware MFA tokens"

  depends_on = [
    module.security_hub
  ]
}

resource "awsutils_security_hub_control_disablement" "ec2_multiple_enis" {
  # This control is not supported in the AN3 region
  count       = local.enabled && local.region_name != "ap-northeast-3" ? 1 : 0
  control_arn = "arn:${local.partition}:securityhub:${local.region_name}:${local.account_id}:control/aws-foundational-security-best-practices/v/1.0.0/EC2.17"
  reason      = "EKS Requires using multiple ENIs"

  depends_on = [
    module.security_hub
  ]
}
