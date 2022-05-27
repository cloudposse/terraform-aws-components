module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component               = "dns-delegated"

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component               = "account-map"
  environment             = "gbl"
  stage                   = "root"

  context = module.this.context
}
