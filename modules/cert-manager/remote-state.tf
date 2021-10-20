module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  stack_config_local_path = "../../../stacks"
  component               = "eks"

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  stack_config_local_path = "../../../stacks"
  component               = "dns-delegated"
  environment             = "gbl"

  context = module.this.context
}
