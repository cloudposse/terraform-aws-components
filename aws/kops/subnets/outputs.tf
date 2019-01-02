output "iprange" {
  value = "${var.iprange}"
}

output "cidrs" {
  value = "${join(",", data.null_data_source.subnets.*.outputs.cidr)}"
}
