module "prometheus" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.prometheus_component_name

  stage       = length(var.prometheus_stage_name) > 0 ? var.prometheus_stage_name : module.this.stage
  environment = length(var.prometheus_environment_name) > 0 ? var.prometheus_environment_name : module.this.environment
  tenant      = length(var.prometheus_tenant_name) > 0 ? var.prometheus_tenant_name : module.this.tenant

  context = module.this.context
}
