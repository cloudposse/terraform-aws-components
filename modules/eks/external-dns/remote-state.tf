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
  environment = var.dns_gbl_delegated_environment_name

  context = module.this.context

  defaults = {
    zones = {}
  }
}
