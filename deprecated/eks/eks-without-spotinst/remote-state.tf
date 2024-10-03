module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  for_each = toset(var.allow_ingress_from_vpc_stages)

  component = "vpc"
  stage     = each.key

  context = module.this.context
}

module "primary_roles" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "iam-primary-roles"

  tenant      = local.iam_primary_roles_tenant_name
  environment = var.iam_roles_environment_name
  stage       = var.iam_primary_roles_stage_name

  context = module.this.context
}

module "delegated_roles" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "iam-delegated-roles"

  environment = var.iam_roles_environment_name

  context = module.this.context
}

# Yes, this is self-referential.
# It obtains the previous state of the cluster so that we can add
# to it rather than overwrite it (specifically the aws-auth configMap)
module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.eks_component_name

  defaults = {
    eks_managed_node_workers_role_arns = []
  }

  context = module.this.context
}
