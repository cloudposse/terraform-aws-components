module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}
