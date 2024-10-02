locals {
  enabled = module.this.enabled
}

# connects two transit gateways that are cross region
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  count                   = local.enabled ? 1 : 0
  provider                = aws.tgw_this_region
  peer_account_id         = module.account_map.outputs.full_account_map[format(var.home_region.tgw_name_format, var.home_region.tgw_tenant_name, var.home_region.tgw_stage_name)]
  peer_region             = var.home_region.region
  peer_transit_gateway_id = module.tgw_home_region.outputs.transit_gateway_id
  transit_gateway_id      = module.tgw_this_region.outputs.transit_gateway_id
  tags                    = module.this.tags
}

# accepts the above
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  count                         = local.enabled ? 1 : 0
  provider                      = aws.tgw_home_region
  transit_gateway_attachment_id = join("", aws_ec2_transit_gateway_peering_attachment.tgw_peering.*.id)
  tags                          = module.this.tags
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_associate_peering_in_region" {
  count      = local.enabled ? 1 : 0
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]

  provider                       = aws.tgw_this_region
  transit_gateway_attachment_id  = join("", aws_ec2_transit_gateway_peering_attachment.tgw_peering.*.id)
  transit_gateway_route_table_id = module.tgw_this_region.outputs.transit_gateway_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_associate_peering_cross_region" {
  count      = local.enabled ? 1 : 0
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]

  provider                       = aws.tgw_home_region
  transit_gateway_attachment_id  = join("", aws_ec2_transit_gateway_peering_attachment.tgw_peering.*.id)
  transit_gateway_route_table_id = module.tgw_home_region.outputs.transit_gateway_route_table_id
}
