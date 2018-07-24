module "kops_metadata" {
  source   = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.1.2"
  dns_zone = "${var.region}.${var.zone_name}"
}
