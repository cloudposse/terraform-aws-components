module "audit" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "audit"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "audit_name_servers" {
  value = "${module.audit.name_servers}"
}
