module "association_resource_components" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  count = var.association_resource_component_selectors

  component   = var.association_resource_component_selectors[count.index].component
  namespace   = try(coalesce(lookup(var.association_resource_component_selectors[count.index], "namespace", null), module.this.namespace), null)
  tenant      = try(coalesce(lookup(var.association_resource_component_selectors[count.index], "tenant", null), module.this.tenant), null)
  environment = try(coalesce(lookup(var.association_resource_component_selectors[count.index], "environment", null), module.this.environment), null)
  stage       = try(coalesce(lookup(var.association_resource_component_selectors[count.index], "stage", null), module.this.stage), null)

  context = module.this.context
}
