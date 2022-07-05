module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component = "vpc"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  count = var.use_eks_security_group ? 1 : 0

  component = "eks"

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component   = "dns-delegated"
  environment = var.dns_gbl_delegated_environment_name

  context = module.this.context
}
