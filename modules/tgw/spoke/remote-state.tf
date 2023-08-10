locals {
  # Any cross region connection requires a TGW Hub connector deployed
  # If any connections given are cross-region, get the `tgw/cross-region-hub-connector` component from that region
  connected_environments = distinct(compact(concat([for c in var.connections : c.account.environment], [module.this.environment])))
}

module "tgw_hub" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.tgw_hub_component_name
  tenant    = length(var.tgw_hub_tenant_name) > 0 ? var.tgw_hub_tenant_name : module.this.tenant
  stage     = length(var.tgw_hub_stage_name) > 0 ? var.tgw_hub_stage_name : module.this.stage

  context = module.this.context
}

module "cross_region_hub_connector" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = toset(local.connected_environments)

  component   = "tgw/cross-region-hub-connector"
  tenant      = length(var.tgw_hub_tenant_name) > 0 ? var.tgw_hub_tenant_name : module.this.tenant
  stage       = length(var.tgw_hub_stage_name) > 0 ? var.tgw_hub_stage_name : module.this.stage
  environment = each.value

  # Ignore if hub connector doesnt exist (it doesnt exist in primary region)
  ignore_errors = true
  defaults      = {}

  context = module.this.context
}
