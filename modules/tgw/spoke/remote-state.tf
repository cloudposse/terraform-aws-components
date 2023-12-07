module "tgw_hub" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.tgw_hub_component_name
  tenant    = length(var.tgw_hub_tenant_name) > 0 ? var.tgw_hub_tenant_name : module.this.tenant
  stage     = length(var.tgw_hub_stage_name) > 0 ? var.tgw_hub_stage_name : module.this.stage

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.own_vpc_component_name

  context = module.this.context
}

module "cross_region_hub_connector" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = var.cross_region_hub_connector_components

  component   = each.value.component
  tenant      = length(var.tgw_hub_tenant_name) > 0 ? var.tgw_hub_tenant_name : module.this.tenant
  stage       = length(var.tgw_hub_stage_name) > 0 ? var.tgw_hub_stage_name : module.this.stage
  environment = each.value.environment

  # Ignore if hub connector doesnt exist (it doesnt exist in primary region)
  ignore_errors = true
  defaults      = {}

  context = module.this.context
}
