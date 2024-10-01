output "tg_config" {
  ## Fit tg config type https://github.com/cloudposse/terraform-aws-transit-gateway#input_config
  value = {
    vpc_id                            = null
    vpc_cidr                          = null
    subnet_ids                        = null
    subnet_route_table_ids            = null
    route_to                          = null
    route_to_cidr_blocks              = null
    static_routes                     = var.static_routes
    transit_gateway_vpc_attachment_id = module.standard_vpc_attachment.transit_gateway_vpc_attachment_ids[var.owning_account]
  }
  description = "Transit Gateway configuration formatted for handling"
}
