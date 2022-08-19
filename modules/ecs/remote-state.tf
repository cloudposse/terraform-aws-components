module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "vpc"

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component   = var.dns_delegated_component_name
  stage       = var.dns_delegated_stage_name
  environment = var.dns_delegated_environment_name

  context = module.this.context
}
