module "identity" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "identity"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "identity_name_servers" {
  value = "${module.identity.name_servers}"
}
