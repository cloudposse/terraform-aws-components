module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component = "eks"

  context = module.this.context
}
