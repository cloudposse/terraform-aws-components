module "accounts" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component  = "account"
  privileged = true

  context = module.this.context
}
