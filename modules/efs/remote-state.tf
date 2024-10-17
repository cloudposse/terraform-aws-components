module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.eks_security_group_enabled ? var.eks_component_names : toset([])

  component = each.key

  context = module.this.context
}

module "gbl_dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "dns-delegated"
  environment = var.dns_gbl_delegated_environment_name

  context = module.this.context
}
