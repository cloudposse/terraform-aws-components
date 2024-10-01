locals {
  enabled         = module.this.enabled
  logging_enabled = local.enabled && var.logging_enabled

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration
  logging_config = local.logging_enabled ? {
    flow = {
      log_destination_type = "S3"
      log_type             = "FLOW"
      log_destination = {
        bucketName = try(module.flow_logs_bucket.outputs.bucket_id, "")
        prefix     = null
      }
    },
    alert = {
      log_destination_type = "S3"
      log_type             = "ALERT"
      log_destination = {
        bucketName = try(module.alert_logs_bucket.outputs.bucket_id, "")
        prefix     = null
      }
    }
  } : {}

  vpc_outputs         = module.vpc.outputs
  firewall_subnet_ids = local.vpc_outputs.named_private_subnets_map[var.firewall_subnet_name]
}

module "network_firewall" {
  source  = "cloudposse/network-firewall/aws"
  version = "0.3.2"

  vpc_id     = local.vpc_outputs.vpc_id
  subnet_ids = local.firewall_subnet_ids

  network_firewall_name                     = var.network_firewall_name
  network_firewall_description              = var.network_firewall_description
  network_firewall_policy_name              = var.network_firewall_policy_name
  policy_stateful_engine_options_rule_order = var.policy_stateful_engine_options_rule_order
  stateful_default_actions                  = var.stateful_default_actions
  stateless_default_actions                 = var.stateless_default_actions
  stateless_fragment_default_actions        = var.stateless_fragment_default_actions
  stateless_custom_actions                  = var.stateless_custom_actions
  delete_protection                         = var.delete_protection
  firewall_policy_change_protection         = var.firewall_policy_change_protection
  subnet_change_protection                  = var.subnet_change_protection

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration
  logging_config = local.logging_config

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group
  rule_group_config = var.rule_group_config

  context = module.this.context
}
