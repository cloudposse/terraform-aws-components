variable "request_acm_certificate" {
  type        = bool
  default     = true
  description = "Whether or not to create an ACM certificate"
}

locals {
  certificate_enabled = local.enabled && var.request_acm_certificate

  # Should this be set for all ACM certs or should be set differently per each ?
  alternative_names = [for zone in var.zone_config : format("*.%s.%s", zone.subdomain, zone.zone_name)]
}

module "acm" {
  for_each = local.zone_map

  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.17.0"

  enabled = local.certificate_enabled

  domain_name = format("%s.%s", each.key, each.value)
  zone_id     = local.aws_route53_zone[each.key].zone_id

  process_domain_validation_options = true
  ttl                               = 300
  subject_alternative_names         = local.alternative_names

  certificate_authority_arn = local.certificate_enabled && local.private_ca_enabled ? module.private_ca[0].outputs.private_ca[var.certificate_authority_component_key].certificate_authority.arn : null
  validation_method         = local.certificate_enabled && local.private_ca_enabled ? null : "DNS"

  context    = module.this.context
  depends_on = [aws_route53_record.root_ns]
}

resource "aws_ssm_parameter" "acm_arn" {
  for_each = local.certificate_enabled ? local.zone_map : {}

  name        = format("/acm/%s.%s", each.key, each.value)
  value       = module.acm[each.key].arn
  description = "ACM certificate id"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}

output "certificate" {
  value       = local.certificate_enabled ? module.acm : null
  description = "The ACM certificate information."
}

output "acm_ssm_parameter" {
  value       = aws_ssm_parameter.acm_arn
  description = "The SSM parameter for the ACM cert."
  sensitive   = true
}
