module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component = "vpc"

  context = module.this.context
}
