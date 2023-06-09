module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.eks_component_name

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}

module "dns_gbl_primary" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "dns-primary"
  environment = "gbl"

  # Ignore errors if component doesnt exist
  ignore_errors = true

  # Set empty zone set if component does exist but doesnt have any zones
  defaults = {
    zones = {}
  }

  context = module.this.context
}
