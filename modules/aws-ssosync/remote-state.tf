module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "account-map"
  environment = var.global_environment_name
  stage       = var.global_stage_name
  privileged  = var.privileged

  context = module.this.context
}

module "tfstate" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "tfstate-backend"
  environment = var.tfstate_environment_name
  stage       = var.global_stage_name
  privileged  = var.privileged

  context = module.this.context
}
