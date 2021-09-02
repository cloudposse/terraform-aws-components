module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.13.0"

  component               = "vpc"
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.13.0"

  stack_config_local_path = "../../../stacks"
  component               = "eks"

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.13.0"

  component               = "dns-delegated"
  stack_config_local_path = "../../../stacks"
  environment             = "gbl"

  context = module.this.context
}
