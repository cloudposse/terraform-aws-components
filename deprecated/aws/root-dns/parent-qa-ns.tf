module "qa" {
  source           = "ns"
  accounts_enabled = "${var.accounts_enabled}"
  namespace        = "${var.namespace}"
  stage            = "qa"
  zone_id          = "${aws_route53_zone.parent_dns_zone.zone_id}"
  account          = "staging"
  key              = "qa-dns/terraform.tfstate"
}

output "qa_name_servers" {
  value = "${module.qa.name_servers}"
}
