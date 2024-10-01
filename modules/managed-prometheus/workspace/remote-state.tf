module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  tenant      = var.account_map_tenant_name
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.vpc_endpoint_enabled ? 1 : 0

  component = "vpc"

  context = module.this.context
}
