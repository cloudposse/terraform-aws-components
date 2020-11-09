module "prod" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "prod"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "prod_name_servers" {
  value = "${module.prod.name_servers}"
}
