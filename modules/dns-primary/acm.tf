variable "request_acm_certificate" {
  type        = bool
  description = "Whether or not to request an ACM certificate for each domain"
  default     = false
}

locals {
  certificate_enabled = module.this.enabled && var.request_acm_certificate
}

module "acm" {
  for_each = local.domains_set

  source = "cloudposse/acm-request-certificate/aws"
  // Note: 0.17.0 is a 'preview' release, so we're using 0.16.2
  version = "0.16.2"

  enabled = local.certificate_enabled

  domain_name                       = each.value
  process_domain_validation_options = true
  ttl                               = 300
  subject_alternative_names         = [format("*.%s", each.value)]

  context    = module.this.context
  depends_on = [aws_route53_record.soa]
}
