locals {
  certificate_verification_dns_record_parts = split(" ", module.amplify_app.domain_association_certificate_verification_dns_record)
}

# Create the SSL certificate validation record
module "certificate_verification_dns_record" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.12.3"

  count = var.certificate_verification_dns_record_enabled ? 1 : 0

  zone_id = module.dns_delegated.outputs.default_dns_zone_id

  dns_name = trimspace(local.certificate_verification_dns_record_parts[0])
  type     = trimspace(local.certificate_verification_dns_record_parts[1])

  records = [
    trimspace(local.certificate_verification_dns_record_parts[2])
  ]

  context = module.this.context
}

# Create DNS records for the subdomains
module "subdomains_dns_record" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.12.3"

  count = var.subdomains_dns_records_enabled && local.domain_config != null ? length(local.domain_config.sub_domain) : 0

  zone_id = module.dns_delegated.outputs.default_dns_zone_id

  dns_name = trimspace(split(" ", tolist(module.amplify_app.sub_domains)[count.index].dns_record)[0])
  type     = trimspace(split(" ", tolist(module.amplify_app.sub_domains)[count.index].dns_record)[1])

  records = [
    trimspace(split(" ", tolist(module.amplify_app.sub_domains)[count.index].dns_record)[2])
  ]

  context = module.this.context
}
