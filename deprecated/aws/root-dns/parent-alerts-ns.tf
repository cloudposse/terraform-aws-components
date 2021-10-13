module "alerts" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "alerts"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "alerts_name_servers" {
  value = "${module.alerts.name_servers}"
}
