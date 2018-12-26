module "dev" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "dev"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "dev_name_servers" {
  value = "${module.dev.name_servers}"
}
