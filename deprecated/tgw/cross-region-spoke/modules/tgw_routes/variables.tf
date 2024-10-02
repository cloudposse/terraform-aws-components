variable "tgw_config" {
  type = object({
    transit_gateway_route_table_id = string
    peering_attachment_id          = any
    vpcs_home_region               = any
    connected_vpcs                 = set(string)
  })
  description = "TGW cross region routes configuration"
}
