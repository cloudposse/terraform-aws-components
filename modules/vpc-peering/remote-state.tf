module "requester_vpc" {
  count = var.requester_vpc_id == null ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.requester_vpc_component_name

  context = module.this.context
}
