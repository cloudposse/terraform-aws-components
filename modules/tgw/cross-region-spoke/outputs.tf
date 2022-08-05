output "vpc_routes_this" {
  value = module.vpc_routes_this
}

output "tgw_routes_in_region" {
  value = module.tgw_routes_this_region
}

output "vpc_routes_home" {
  value = module.vpc_routes_home
}

output "tgw_routes_home_region" {
  value = module.tgw_routes_home_region
}
#
#output "tgw_this_region" {
#  value = module.tgw_this_region
#}
#
#output "vpcs_this_region" {
#  value = module.vpcs_this_region
#}
