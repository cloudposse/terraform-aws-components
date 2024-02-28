locals {
  enabled = module.this.enabled

  domain_suffix = format("%s.%s", var.environment, module.dns_delegated.outputs.default_domain_name)

  domain_name = length(var.domain_name) > 0 ? var.domain_name : format("%s.%s", var.domain_name_prefix, local.domain_suffix)

  subject_alternative_names = concat(var.subject_alternative_names, formatlist("%s.${local.domain_suffix}", var.subject_alternative_names_prefixes))
  all_sans                  = distinct(concat([format("*.%s", local.domain_name)], local.subject_alternative_names))

  private_enabled = local.enabled && var.dns_private_zone_enabled

  private_ca_enabled = local.private_enabled && var.certificate_authority_enabled
}

data "aws_route53_zone" "default" {
  count        = local.enabled && var.process_domain_validation_options ? 1 : 0
  name         = length(var.zone_name) > 0 ? var.zone_name : module.dns_delegated.outputs.default_domain_name
  private_zone = local.private_enabled
}

# https://github.com/cloudposse/terraform-aws-acm-request-certificate
module "acm" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.16.3"

  certificate_authority_arn         = local.private_ca_enabled ? module.private_ca[0].outputs.private_ca[var.certificate_authority_component_key].certificate_authority.arn : null
  validation_method                 = local.private_ca_enabled ? null : var.validation_method
  domain_name                       = local.domain_name
  process_domain_validation_options = var.process_domain_validation_options
  ttl                               = 300
  subject_alternative_names         = local.all_sans
  zone_id                           = join("", data.aws_route53_zone.default.*.zone_id)

  context = module.this.context
}

resource "aws_ssm_parameter" "acm_arn" {
  count = local.enabled ? 1 : 0

  name        = "/acm/${local.domain_name}"
  value       = module.acm.arn
  description = format("ACM certificate ARN for '%s' domain", local.domain_name)
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}
