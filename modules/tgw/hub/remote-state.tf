locals {
  accounts_with_eks = {
    for account in var.accounts_with_eks :
    account => module.account_map.outputs.account_info_map[account]
  }

  accounts_with_vpc = {
    for account in var.accounts_with_vpc :
    account => module.account_map.outputs.account_info_map[account]
  }

  # Create a map of accounts (<tenant>-<stage> or <stage>) and components
  eks_remote_states = {
    for account_component in setproduct(keys(local.accounts_with_eks), var.eks_component_names) :
    join("-", account_component) => {
      account   = account_component[0]
      component = account_component[1]
    }
  }
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "account-map"
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name
  tenant      = coalesce(var.account_map_tenant_name, module.this.tenant)

  context = module.this.context
}

module "vpc" {
  for_each = local.accounts_with_vpc

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"
  stage     = each.value.stage
  tenant    = lookup(each.value, "tenant", null)

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  for_each = local.eks_remote_states

  component = each.value.component
  stage     = try(split("-", each.value.account)[1], each.value.account)
  tenant    = try(split("-", each.value.account)[0], null)

  defaults = {
    eks_cluster_managed_security_group_id = null
  }

  context = module.this.context
}
