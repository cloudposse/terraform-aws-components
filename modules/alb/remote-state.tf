module "remote_vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.vpc_component_name

  context = module.this.context
}

module "remote_dns" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.dns_delegated_component_name

  # Ignore errors if component doesnt exist
  ignore_errors = true

  context = module.this.context
}

module "remote_acm" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.acm_component_name

  # Ignore errors if component doesnt exist
  ignore_errors = true

  context = module.this.context
}
