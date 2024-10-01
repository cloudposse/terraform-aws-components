module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "eks"

  bypass = !var.eks_security_group_ingress_enabled

  defaults = {
    eks_cluster_managed_security_group_id : ""
  }

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "dns-delegated"

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  stack_config_local_path = "../../../stacks"
  component               = "dns-delegated"
  environment             = "gbl"

  context = module.this.context
}
