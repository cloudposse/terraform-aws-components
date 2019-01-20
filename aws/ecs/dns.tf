variable "zone_parent_name" {}

variable "zone_enabled" {
  default = "false"
}

module "zone" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-zone.git?ref=tags/0.2.6"
  enabled          = "${var.zone_enabled}"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.aws_region}"
  parent_zone_name = "${var.zone_parent_name}"
  zone_name        = "$${name}.$${parent_zone_name}"
}
