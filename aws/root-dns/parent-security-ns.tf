module "security" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "security"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "security_name_servers" {
  value = "${module.security.name_servers}"
}
