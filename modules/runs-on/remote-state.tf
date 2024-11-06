module "vpc" {
  count = local.enabled && var.vpc_peering_component != null ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.vpc_peering_component.component
  tenant      = var.vpc_peering_component.tenant
  environment = var.vpc_peering_component.environment
  stage       = var.vpc_peering_component.stage

  context = module.this.context
}
