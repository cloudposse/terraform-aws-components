locals {
  account_info_map = module.account_map.outputs.account_info_map
  stages = distinct(
    [for account, account_info in local.account_info_map : account_info.stage]
  )
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component   = "account-map"
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name
  tenant      = coalesce(var.account_map_tenant_name, module.this.tenant)

  context = module.this.context
}
