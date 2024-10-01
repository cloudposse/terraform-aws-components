module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  environment = "gbl"
  component   = "dns-delegated"

  context = module.this.context
}
