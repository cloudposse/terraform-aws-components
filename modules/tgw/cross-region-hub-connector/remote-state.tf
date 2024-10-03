locals {
  primary_tgw_hub_environment = module.utils.region_az_alt_code_maps[var.env_naming_convention][var.primary_tgw_hub_region]
}

# Used to translate region to environment
module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.3.0"
  enabled = local.enabled
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name

  context = module.this.context
}

module "tgw_hub_this_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "tgw/hub"

  context = module.this.context
}

module "tgw_hub_primary_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "tgw/hub"
  stage       = local.primary_tgw_hub_stage
  environment = local.primary_tgw_hub_environment
  tenant      = local.primary_tgw_hub_tenant

  context = module.this.context
}
