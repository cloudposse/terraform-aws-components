output "iprange" {
  value = "${var.iprange}"
}

output "cidrs" {
  value = "${data.null_data_source.subnets.*.outputs.cidr}"
}
