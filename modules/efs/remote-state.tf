module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  component               = "vpc"
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  count = var.use_eks_security_group ? 1 : 0

  component               = "eks"
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  component               = "dns-delegated"
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}
