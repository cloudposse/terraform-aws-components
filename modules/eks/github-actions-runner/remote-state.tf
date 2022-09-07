locals {
  iam_primary_roles_tenant_name = coalesce(var.iam_primary_roles_tenant_name, module.this.tenant)
}

module "team_roles" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "aws-teams"

  tenant      = local.iam_primary_roles_tenant_name
  environment = var.iam_roles_environment_name
  stage       = var.iam_primary_roles_stage_name

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.eks_component_name

  context = module.this.context
}
