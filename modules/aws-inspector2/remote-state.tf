module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component   = "account-map"
  tenant      = var.account_map_tenant != "" ? var.account_map_tenant : module.this.tenant
  stage       = var.root_account_stage
  environment = var.global_environment
  privileged  = var.privileged

  context = module.this.context
}
