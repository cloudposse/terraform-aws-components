locals {
  enabled = module.this.enabled

  pool_configurations = {
    for pool, poolval in var.pool_configurations :
    pool => merge(poolval, {
      locale = lookup(poolval, "locale", join("", data.aws_region.current.*.name))
      sub_pools = {
        for subpool, subval in poolval.sub_pools :
        subpool => merge(subval, {
          ram_share_principals = concat(
            lookup(subval, "ram_share_principals", []),
            tolist(
              setsubtract(
                [
                  for account in lookup(subval, "ram_share_accounts", []) :
                  module.account_map.outputs.full_account_map[account]
                ],
                [join("", data.aws_caller_identity.current.*.account_id)]
              )
            )
          )
          allocation_resource_tags = merge(
            lookup(subval, "allocation_resource_tags", {}),
            module.this.tags
          )
        })
      }
    })
  }
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_region" "current" {
  count = local.enabled ? 1 : 0
}

module "ipam" {
  source  = "aws-ia/ipam/aws"
  version = "1.2.1"

  count = local.enabled ? 1 : 0

  create_ipam = local.enabled

  address_family                 = var.address_family
  ipam_scope_id                  = var.ipam_scope_id
  ipam_scope_type                = var.ipam_scope_type
  pool_configurations            = local.pool_configurations
  top_auto_import                = var.top_auto_import
  top_cidr                       = var.top_cidr
  top_cidr_authorization_context = var.top_cidr_authorization_context
  top_description                = var.top_description
  top_ram_share_principals       = var.top_ram_share_principals
}
