module "dms_replication_instance" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.replication_instance_component_name

  context = module.this.context
}

module "dms_endpoint_source" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.source_endpoint_component_name

  context = module.this.context
}

module "dms_endpoint_target" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.target_endpoint_component_name

  context = module.this.context
}
