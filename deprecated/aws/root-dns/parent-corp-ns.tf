module "corp" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "corp"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "corp_name_servers" {
  value = "${module.corp.name_servers}"
}
