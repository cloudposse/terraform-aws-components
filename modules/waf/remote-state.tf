module "association_resource_components" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.enabled ? length(var.association_resource_component_selectors) : 0

  component   = var.association_resource_component_selectors[count.index].component
  namespace   = coalesce(lookup(var.association_resource_component_selectors[count.index], "namespace", null), module.this.namespace)
  tenant      = coalesce(lookup(var.association_resource_component_selectors[count.index], "tenant", null), module.this.tenant)
  environment = coalesce(lookup(var.association_resource_component_selectors[count.index], "environment", null), module.this.environment)
  stage       = coalesce(lookup(var.association_resource_component_selectors[count.index], "stage", null), module.this.stage)

  context = module.this.context
}

module "log_destination_components" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.enabled ? length(var.log_destination_component_selectors) : 0

  component   = var.log_destination_component_selectors[count.index].component
  namespace   = coalesce(lookup(var.log_destination_component_selectors[count.index], "namespace", null), module.this.namespace)
  tenant      = coalesce(lookup(var.log_destination_component_selectors[count.index], "tenant", null), module.this.tenant)
  environment = coalesce(lookup(var.log_destination_component_selectors[count.index], "environment", null), module.this.environment)
  stage       = coalesce(lookup(var.log_destination_component_selectors[count.index], "stage", null), module.this.stage)

  context = module.this.context
}
