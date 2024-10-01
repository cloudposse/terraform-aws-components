module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  tenant      = var.account_map_tenant != "" ? var.account_map_tenant : module.this.tenant
  stage       = var.root_account_stage
  environment = var.global_environment
  privileged  = var.privileged

  context = module.this.context
}

module "guardduty_delegated_detector" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  # If we are creating the delegated detector (because we are in the delegated admin account), then don't try to lookup
  # the delegated detector ID from remote state
  count = local.create_guardduty_collector ? 0 : 1

  component  = "${var.delegated_administrator_component_name}/${module.this.environment}"
  stage      = replace(var.delegated_administrator_account_name, "${module.this.tenant}-", "")
  privileged = var.privileged

  context = module.this.context
}
