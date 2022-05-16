module "accounts" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component  = "account"
  privileged = true

  context = module.this.context
}
