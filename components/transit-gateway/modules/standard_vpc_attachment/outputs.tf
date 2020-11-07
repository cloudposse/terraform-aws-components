output "tg_config" {
  value = {
    vpc_id                            = null
    vpc_cidr                          = null
    subnet_ids                        = null
    subnet_route_table_ids            = null
    route_to                          = null
    route_to_cidr_blocks              = null
    static_routes                     = null
    transit_gateway_vpc_attachment_id = module.tgw_vpc_attachment.transit_gateway_vpc_attachment_ids[var.owning_account]
  }
}
