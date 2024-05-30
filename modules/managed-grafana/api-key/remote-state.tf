module "managed_grafana" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.grafana_component_name

  context = module.this.context
}
