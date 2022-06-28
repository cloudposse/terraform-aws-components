module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}
