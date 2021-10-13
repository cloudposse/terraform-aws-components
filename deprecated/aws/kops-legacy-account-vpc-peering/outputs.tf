output "accepter_accept_status" {
  description = "Accepter VPC peering connection request status"
  value       = "${module.kops_legacy_account_vpc_peering.accepter_accept_status}"
}

output "accepter_connection_id" {
  description = "Accepter VPC peering connection ID"
  value       = "${module.kops_legacy_account_vpc_peering.accepter_connection_id}"
}

output "requester_accept_status" {
  description = "Requester VPC peering connection request status"
  value       = "${module.kops_legacy_account_vpc_peering.requester_accept_status}"
}

output "requester_connection_id" {
  description = "Requester VPC peering connection ID"
  value       = "${module.kops_legacy_account_vpc_peering.requester_connection_id}"
}
