variable "dns_parent_zone_name" {}

variable "dns_enabled" {
  default = "true"
}

module "dns" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-zone.git?ref=add-attributes"
  enabled          = "${var.dns_enabled}"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.name}"
  parent_zone_name = "${var.dns_parent_zone_name}"
  zone_name        = "$${region}-$${name}.$${parent_zone_name}"
}

output "dns_zone_name" {
  value = "${module.dns.zone_name}"
}
