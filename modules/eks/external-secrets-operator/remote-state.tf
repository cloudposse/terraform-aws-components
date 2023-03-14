module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.eks_component_name

  context = module.this.context
}

module "account_map" {
  source      = "cloudposse/stack-config/yaml//modules/remote-state"
  version     = "1.4.1"
  component   = "account-map"
  tenant      = module.iam_roles.global_tenant_name
  environment = module.iam_roles.global_environment_name
  stage       = module.iam_roles.global_stage_name
  context     = module.this.context
}
