module "accounts" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.0.0"

  component  = "account"
  privileged = true

  context = module.this.context
}
