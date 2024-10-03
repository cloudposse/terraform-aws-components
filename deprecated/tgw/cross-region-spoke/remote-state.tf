module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "account-map"
  stage       = "root"
  environment = "gbl"
  tenant      = var.account_map_tenant_name
  context     = module.this.context
}

module "vpcs_this_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  for_each = toset(concat(tolist(var.this_region.connections), [var.tenant == null ? module.this.stage : format("%s-%s", module.this.tenant, module.this.stage)]))

  tenant = var.tenant != null ? split(module.this.delimiter, each.key)[0] : null
  stage  = var.tenant != null ? split(module.this.delimiter, each.key)[1] : null

  component = "vpc"

  context = module.this.context
}

module "vpcs_home_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  for_each = toset(concat(tolist(var.home_region.connections), [var.tenant == null ? module.this.stage : format("%s-%s", module.this.tenant, module.this.stage)]))

  component   = "vpc"
  tenant      = var.tenant != null ? split(module.this.delimiter, each.key)[0] : null
  stage       = var.tenant != null ? split(module.this.delimiter, each.key)[1] : null
  environment = local.home_environment

  context = module.this.context
}

module "tgw_this_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "tgw/hub"
  stage     = var.this_region["tgw_stage_name"]
  tenant    = var.this_region["tgw_tenant_name"]
  context   = module.this.context
}

module "tgw_cross_region_connector" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "tgw/cross-region-hub-connector"
  stage     = var.this_region["tgw_stage_name"]
  tenant    = var.this_region["tgw_tenant_name"]
  context   = module.this.context
}

module "tgw_home_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "tgw/hub"
  stage       = var.home_region["tgw_stage_name"]
  environment = local.home_environment
  tenant      = var.home_region["tgw_tenant_name"]
  context     = module.this.context
}
