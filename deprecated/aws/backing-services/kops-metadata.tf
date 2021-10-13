variable "kops_metadata_enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = "string"
  default     = "false"
}

module "kops_metadata" {
  source   = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.2.0"
  dns_zone = "${var.region}.${var.zone_name}"
  enabled  = "${var.kops_metadata_enabled}"
}
