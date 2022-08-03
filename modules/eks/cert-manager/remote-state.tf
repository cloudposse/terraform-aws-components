module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component = var.eks_component_name

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}
