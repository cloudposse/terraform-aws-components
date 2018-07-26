module "kops_metadata" {
  source   = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.2.0"
  dns_zone = "${var.region}.${var.zone_name}"
}
