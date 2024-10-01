output "transit_gateway_arn" {
  value       = module.tgw_hub.transit_gateway_arn
  description = "Transit Gateway ARN"
}

output "transit_gateway_id" {
  value       = module.tgw_hub.transit_gateway_id
  description = "Transit Gateway ID"
}

output "transit_gateway_route_table_id" {
  value       = module.tgw_hub.transit_gateway_route_table_id
  description = "Transit Gateway route table ID"
}

output "vpcs" {
  value       = module.vpc
  description = "Accounts with VPC and VPCs information"
}

output "eks" {
  value       = module.eks
  description = "Accounts with EKS and EKSs information"
}

output "tgw_config" {
  value       = local.tgw_config
  description = "Transit Gateway config"
}
