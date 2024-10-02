module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.vpc_component_name

  bypass = !local.physical_connection_enabled

  defaults = {
    private_subnet_ids = []
    vpc_id             = null
  }

  context = module.this.context
}
