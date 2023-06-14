locals {
  accounts_with_vpc = { for i, account in var.allow_ingress_from_vpc_accounts : try(account.tenant, module.this.tenant) != null ? format("%s-%s", account.tenant, account.stage) : account.stage => account }
}

module "iam_arns" {
  source = "../../account-map/modules/roles-to-principals"

  role_map = local.role_map

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.2"

  component = "vpc"

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.2"

  for_each = local.accounts_with_vpc

  component   = "vpc"
  environment = try(each.value.environment, module.this.environment)
  stage       = try(each.value.stage, module.this.environment)
  tenant      = try(each.value.tenant, module.this.tenant)

  context = module.this.context
}

# Yes, this is self-referential.
# It obtains the previous state of the cluster so that we can add
# to it rather than overwrite it (specifically the aws-auth configMap)
module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.2"

  component = var.eks_component_name

  defaults = {
    eks_managed_node_workers_role_arns = []
    fargate_profile_role_arns          = []
    eks_cluster_identity_oidc_issuer   = ""
  }

  context = module.this.context
}
