module "staging" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "staging"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "staging_name_servers" {
  value = "${module.staging.name_servers}"
}
