module "cloudtrail_bucket" {
  count = local.cloudtrail_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.cloudtrail_bucket_component_name

  context = module.this.context
}

module "account_map" {
  source    = "cloudposse/stack-config/yaml//modules/remote-state"
  version   = "1.5.0"
  component = "account-map"

  tenant      = module.iam_roles.global_tenant_name
  environment = module.iam_roles.global_environment_name
  stage       = module.iam_roles.global_stage_name

  context = module.this.context
}
