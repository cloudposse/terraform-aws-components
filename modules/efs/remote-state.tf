module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  for_each = local.eks_security_group_enabled ? var.eks_component_names : toset([])

  component = each.key

  context = module.this.context
}

module "gbl_dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}
