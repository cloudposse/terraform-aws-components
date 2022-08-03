module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component = "vpc"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  for_each = local.eks_security_group_enabled ? var.eks_component_names : toset([])

  component = each.key

  context = module.this.context
}

module "gbl_dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}
