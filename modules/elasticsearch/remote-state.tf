module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "dns-delegated"

  context = module.this.context
}
