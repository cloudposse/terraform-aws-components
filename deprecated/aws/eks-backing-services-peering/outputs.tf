output "vpc_peering_connection_id" {
  value       = "${module.vpc_peering.connection_id}"
  description = "VPC peering connection ID"
}

output "vpc_peering_accept_status" {
  value       = "${module.vpc_peering.accept_status}"
  description = "The status of the VPC peering connection request"
}
