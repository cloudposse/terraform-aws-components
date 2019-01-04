module "data" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "data"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "data_name_servers" {
  value = "${module.data.name_servers}"
}
