locals {
  enabled = module.this.enabled
  routable_cidrs = toset([
    for k, v in var.tgw_config.vpcs_home_region : v.outputs.vpc_cidr
    if contains(var.tgw_config.connected_vpcs, k)
  ])
}

resource "aws_ec2_transit_gateway_route" "default" {
  for_each                       = local.enabled ? local.routable_cidrs : []
  blackhole                      = false
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.tgw_config.peering_attachment_id
  transit_gateway_route_table_id = var.tgw_config.transit_gateway_route_table_id
}
