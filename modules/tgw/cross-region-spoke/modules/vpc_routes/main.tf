locals {
  enabled         = module.this.enabled
  own_vpc         = local.enabled ? var.vpc_config.vpcs_this_region[var.vpc_name].outputs : null
  route_table_ids = local.enabled ? local.own_vpc.private_route_table_ids : []

  allowed_cidrs = [
    for k, v in var.vpc_config.vpcs_home_region : v.outputs.vpc_cidr
    if contains(var.vpc_config.connected_vpcs, k)
  ]
  #  allowed_cidrs = [var.vpc_config.vpcs_home_region.outputs.vpc_cidr]

  route_config_provided = length(local.route_table_ids) > 0 && length(local.allowed_cidrs) > 0
  route_config_list     = local.route_config_provided ? [for i in setproduct(local.route_table_ids, local.allowed_cidrs) : i] : []
  # Store in map to avoid resource replacement due to list reordering
  route_config_map = local.route_config_provided ? { for i in local.route_config_list : format("%v:%v", i[0], i[1]) => i } : {}
}

resource "aws_route" "route" {
  for_each               = local.enabled ? local.route_config_map : {}
  transit_gateway_id     = var.vpc_config.transit_gateway_id
  route_table_id         = each.value[0]
  destination_cidr_block = each.value[1]
}
