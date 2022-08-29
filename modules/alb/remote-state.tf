module "remote_vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "vpc"

  context = module.this.context
}

module "remote_dns" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "dns-delegated"

  context = module.this.context
}
