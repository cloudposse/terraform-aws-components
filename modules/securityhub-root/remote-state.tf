module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.2"

  component   = "account-map"
  stage       = var.root_account_stage
  environment = var.global_environment
  privileged  = var.privileged

  context = module.this.context
}
