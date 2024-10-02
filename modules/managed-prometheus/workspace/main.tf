locals {
  enabled = module.this.enabled

  grafana_account_id = local.enabled && length(var.grafana_account_name) > 0 ? module.account_map.outputs.full_account_map[var.grafana_account_name] : ""

  vpc_endpoint_enabled = module.this.enabled && var.vpc_endpoint_enabled
}

module "managed_prometheus" {
  source  = "cloudposse/managed-prometheus/aws"
  version = "0.1.1"

  enabled = local.enabled

  alert_manager_definition = var.alert_manager_definition
  allowed_account_id       = local.grafana_account_id
  rule_group_namespaces    = var.rule_group_namespaces
  scraper_deployed         = true

  vpc_id = local.vpc_endpoint_enabled ? module.vpc[0].outputs.vpc_id : ""

  context = module.this.context
}
