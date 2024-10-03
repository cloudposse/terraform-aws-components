locals {
  accounts_with_vpc = local.enabled ? {
    for i, account in var.allow_ingress_from_vpc_accounts : try(account.tenant, module.this.tenant) != null ? format("%s-%s-%s", account.tenant, account.stage, try(account.environment, module.this.environment)) : format("%s-%s", account.stage, try(account.environment, module.this.environment)) => account
  } : {}
}

module "iam_arns" {
  source = "../../account-map/modules/roles-to-principals"

  role_map = local.role_map

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  bypass    = !local.enabled
  component = var.vpc_component_name

  defaults = {
    public_subnet_ids  = []
    private_subnet_ids = []
    vpc = {
      subnet_type_tag_key = ""
    }
    vpc_cidr = null
    vpc_id   = null
  }

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.accounts_with_vpc

  component   = var.vpc_component_name
  environment = try(each.value.environment, module.this.environment)
  stage       = try(each.value.stage, module.this.stage)
  tenant      = try(each.value.tenant, module.this.tenant)

  context = module.this.context
}

