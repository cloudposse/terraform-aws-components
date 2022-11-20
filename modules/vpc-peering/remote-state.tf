module "requester_vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component = var.requester_vpc_component_name

  context = module.this.context
}
