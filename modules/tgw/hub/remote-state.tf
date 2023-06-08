locals {
  vpc_connections = flatten([for connection in var.connections : [
    for vpc_component_name in connection.vpc_component_names : {
      stage     = connection.account.stage
      tenant    = lookup(connection.account, "tenant", null)
      component = vpc_component_name
    }]
  ])

  eks_connections = flatten([for connection in var.connections : [
    for eks_component_name in connection.eks_component_names : {
      stage     = connection.account.stage
      tenant    = lookup(connection.account, "tenant", null)
      component = eks_component_name
    }]
  ])

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
  for_each = { for c in local.vpc_connections :
    (length(c.tenant) > 0 ? "${c.tenant}-${c.stage}-${c.component}" : "${c.stage}-${c.component}")
  => c }

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = each.value.component
  stage     = each.value.stage
  tenant    = lookup(each.value, "tenant", null)

  context = module.this.context
}

module "eks" {
  for_each = { for c in local.eks_connections :
    (length(c.tenant) > 0 ? "${c.tenant}-${c.stage}-${c.component}" : "${c.stage}-${c.component}")
  => c }

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = each.value.component
  stage     = each.value.stage
  tenant    = lookup(each.value, "tenant", null)

  defaults = {
    eks_cluster_managed_security_group_id = null
  }

  context = module.this.context
}
