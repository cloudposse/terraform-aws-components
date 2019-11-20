variable "dns_parent_zone_name" {
  description = "DNS zone of parent domain that will delegate NS records to this cluster zone (e.g. `prod.example.co`)"
}

variable "dns_enabled" {
  default = true
}

variable "dns_zone_name" {
  description = "Zone name template"
  default     = "$$${region}-$$${name}.$$${parent_zone_name}"
}

module "dns" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-zone.git?ref=tags/0.4.0"
  enabled          = var.dns_enabled
  namespace        = var.namespace
  stage            = var.stage
  name             = var.name
  parent_zone_name = var.dns_parent_zone_name
  zone_name        = var.dns_zone_name
}

output "dns_zone_name" {
  value = module.dns.zone_name
}
