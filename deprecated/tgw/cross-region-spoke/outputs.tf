output "vpc_routes_this" {
  value       = module.vpc_routes_this
  description = "This modules VPC routes"
}

output "tgw_routes_in_region" {
  value       = module.tgw_routes_this_region
  description = "TGW routes in this region"
}

output "vpc_routes_home" {
  value       = module.vpc_routes_home
  description = "VPC routes to the primary VPC"
}

output "tgw_routes_home_region" {
  value       = module.tgw_routes_home_region
  description = "TGW Routes to the primary region"
}
#
#output "tgw_this_region" {
#  value = module.tgw_this_region
#}
#
#output "vpcs_this_region" {
#  value = module.vpcs_this_region
#}
