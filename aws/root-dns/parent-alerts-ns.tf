module "alerts" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "alerts"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
  account          = "corp"
  key              = "alerts-dns/terraform.tfstate"
}

output "alerts_name_servers" {
  value = "${module.alerts.name_servers}"
}
