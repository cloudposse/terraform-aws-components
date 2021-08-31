module "vpc_primary" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  stack_config_local_path = "../../../stacks"
  component               = "vpc"

  context = module.this.context
}

module "vpc_secondary" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  count = var.secondary_region_enabled ? 1 : 0

  stack_config_local_path = "../../../stacks"
  component               = "vpc"
  environment             = var.environment_secondary

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  count = var.use_eks_security_group ? 1 : 0

  stack_config_local_path = "../../../stacks"
  component               = "eks"

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  stack_config_local_path = "../../../stacks"
  component               = "dns-delegated"
  environment             = var.dns_gbl_delegated_environment_name

  context = module.this.context
}
