module "vpc_routes_this" {
  source = "./modules/vpc_routes"

  vpc_name = var.tenant == null ? module.this.stage : format("%s-%s", module.this.tenant, module.this.stage)

  vpc_config = local.vpc_config_this_region
  context    = module.this.context
}

module "tgw_routes_this_region" {
  source = "./modules/tgw_routes"
  providers = {
    aws = aws.tgw_this_region
  }

  tgw_config = local.tgw_config_in_region
  context    = module.this.context
}

locals {
  vpc_config_this_region = {
    transit_gateway_id = module.tgw_this_region.outputs.transit_gateway_id
    vpcs_this_region   = module.vpcs_this_region
    vpcs_home_region   = module.vpcs_home_region
    connected_vpcs     = var.this_region.connections
  }
  tgw_config_in_region = {
    transit_gateway_route_table_id = module.tgw_this_region.outputs.transit_gateway_route_table_id
    peering_attachment_id          = module.tgw_cross_region_connector.outputs.aws_ec2_transit_gateway_peering_attachment_id
    vpcs_home_region               = module.vpcs_home_region
    connected_vpcs                 = var.this_region.connections
  }
}
