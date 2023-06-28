module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component   = "account-map"
  environment = module.iam_roles.global_environment_name
  stage       = module.iam_roles.global_stage_name
  tenant      = module.iam_roles.global_tenant_name
  privileged  = var.privileged

  context = module.this.context
}

# Module "iam_roles" is usually in providers.tf, but not so for this component

module "iam_roles" {
  source  = "../account-map/modules/iam-roles"
  context = module.this.context
}
