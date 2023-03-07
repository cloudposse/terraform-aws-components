module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  stack_config_local_path = "../../../stacks"
  component               = "vpc"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  stack_config_local_path = "../../../stacks"
  component               = "eks"

  context = module.this.context
}
