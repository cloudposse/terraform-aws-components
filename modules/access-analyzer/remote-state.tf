module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  tenant      = (var.account_map_tenant != "") ? var.account_map_tenant : module.this.tenant
  stage       = var.root_account_stage
  environment = var.global_environment

  context = module.this.context
}
