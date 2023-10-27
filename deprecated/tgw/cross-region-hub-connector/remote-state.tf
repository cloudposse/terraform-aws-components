module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "account-map"
  stage       = "root"
  environment = "gbl"
  tenant      = var.account_map_tenant_name
  context     = module.this.context
}

module "tgw_this_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "tgw/hub"
  stage     = var.this_region["tgw_stage_name"]
  tenant    = var.this_region["tgw_tenant_name"]
  context   = module.this.context
}

module "tgw_home_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "tgw/hub"
  stage       = var.home_region["tgw_stage_name"]
  environment = var.home_region["environment"]
  tenant      = var.home_region["tgw_tenant_name"]
  context     = module.this.context
}
