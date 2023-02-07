locals {
  accounts_with_vpc = { for i, account in var.allow_ingress_from_vpc_accounts : try(account.tenant, module.this.tenant) != null ? format("%s-%s", account.tenant, account.stage) : account.stage => account }
}

module "dns-delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  for_each = var.eks_component_names

  component = each.value

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component = "vpc"

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  for_each = local.accounts_with_vpc

  component   = "vpc"
  environment = try(each.value.environment, module.this.environment)
  stage       = try(each.value.stage, module.this.environment)
  tenant      = try(each.value.tenant, module.this.tenant)

  context = module.this.context
}


module "primary_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  count = local.remote_read_replica_enabled ? 1 : 0

  component   = var.primary_cluster_component
  environment = var.primary_cluster_region

  context = module.this.context
}
