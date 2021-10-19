module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  stack_config_local_path = "../../../stacks"
  component               = "eks"

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  component               = "dns-delegated"
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  component               = "dns-delegated"
  environment             = var.dns_gbl_delegated_environment_name
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}
