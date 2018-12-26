module "testing" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "testing"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "testing_name_servers" {
  value = "${module.testing.name_servers}"
}
