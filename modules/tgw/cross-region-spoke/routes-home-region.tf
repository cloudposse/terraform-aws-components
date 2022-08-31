module "vpc_routes_home" {
  source = "./modules/vpc_routes"

  vpc_name = var.tenant == null ? module.this.stage : format("%s-%s", module.this.tenant, module.this.stage)
  # Wherever you deploy this component, but in your home region.
  # e.g. you normally deploy to region-a, tgw is in network account. this component is deployed to region-b dev
  # This creates the routes in region-a dev
  providers = {
    aws = aws.this_home
  }

  vpc_config = local.vpc_config_home_region
  context    = module.this.context
}

module "tgw_routes_home_region" {
  source = "./modules/tgw_routes"
  providers = {
    aws = aws.tgw_home_region
  }

  tgw_config = local.tgw_config_home_region
  context    = module.this.context
}

locals {
  vpc_config_home_region = {
    transit_gateway_id = module.tgw_home_region.outputs.transit_gateway_id
    # Reverse the view for the home region
    vpcs_this_region = module.vpcs_home_region
    vpcs_home_region = module.vpcs_this_region
    connected_vpcs   = var.home_region.connections
  }
  tgw_config_home_region = {
    transit_gateway_route_table_id = module.tgw_home_region.outputs.transit_gateway_route_table_id
    peering_attachment_id          = module.tgw_cross_region_connector.outputs.aws_ec2_transit_gateway_peering_attachment_id
    # Reverse the view for the home region
    vpcs_home_region = module.vpcs_this_region
    connected_vpcs   = var.home_region.connections
  }
}
