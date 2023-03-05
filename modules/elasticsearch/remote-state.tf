module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  stack_config_local_path = "../../../stacks"
  component               = "vpc"

  context = module.this.context
  enabled = true
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  stack_config_local_path = "../../../stacks"
  component               = "dns-delegated"

  context = module.this.context
  enabled = true
}
