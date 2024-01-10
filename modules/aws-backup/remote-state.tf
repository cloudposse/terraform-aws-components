module "copy_destination_vault" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.copy_action_enabled ? 1 : 0

  component   = var.destination_vault_component_name
  environment = var.destination_vault_region

  context = module.this.context
}
