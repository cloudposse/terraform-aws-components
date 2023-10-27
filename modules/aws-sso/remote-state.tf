module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  environment = module.iam_roles.global_environment_name
  stage       = module.iam_roles.global_stage_name
  tenant      = module.iam_roles.global_tenant_name
  privileged  = var.privileged

  context = module.this.context
}
