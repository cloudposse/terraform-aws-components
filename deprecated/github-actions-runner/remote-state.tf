module "iam_primary_roles" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component   = "iam-primary-roles"
  environment = var.iam_primary_roles_environment_name
  stage       = var.iam_primary_roles_stage_name

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component = "eks"

  context = module.this.context
}
