module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component   = "account-map"
  privileged  = var.privileged
  environment = var.global_environment_name
  stage       = var.root_account_stage_name
  tenant      = var.root_account_tenant_name

  context = module.always.context
}

locals {
  account_name = lookup(module.always.descriptors, "account_name", module.always.stage)
}
