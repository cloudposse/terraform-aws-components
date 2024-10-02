module "tgw_hub" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = var.tgw_hub_component_name
  stage       = var.tgw_hub_stage_name
  environment = var.tgw_hub_environment_name
  tenant      = var.tgw_hub_tenant_name

  context = module.this.context
}
