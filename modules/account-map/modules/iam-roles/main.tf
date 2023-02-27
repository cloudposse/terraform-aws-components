module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "account-map"
  privileged  = var.privileged
  tenant      = var.global_tenant_name
  environment = var.global_environment_name
  stage       = var.global_stage_name

  context = module.always.context
}

locals {
  account_name = lookup(module.always.descriptors, "account_name", module.always.stage)
}
