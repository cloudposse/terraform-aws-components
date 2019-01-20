variable "dns_parent_zone_name" {}

variable "dns_enabled" {
  default = "false"
}

module "dns" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-zone.git?ref=tags/0.2.6"
  enabled          = "${var.dns_enabled}"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.aws_region}"
  parent_zone_name = "${var.dns_parent_zone_name}"
  zone_name        = "$${name}.$${parent_zone_name}"
}
