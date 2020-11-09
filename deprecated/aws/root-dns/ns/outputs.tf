output "stage" {
  description = "Name of the subaccount corresponding to the name servers"
  value       = "${var.stage}"
}

output "name_servers" {
  description = "Name servers for the account's delegated DNS zone"
  value       = "${local.name_servers}"
}
