locals {
  enabled = module.this.enabled

  private_enabled = local.enabled && var.dns_private_zone_enabled

  private_ca_enabled = local.private_enabled && var.certificate_authority_enabled
}

data "aws_route53_zone" "default" {
  count        = local.enabled ? 1 : 0
  name         = var.zone_name
  private_zone = local.private_enabled
}

# https://github.com/cloudposse/terraform-aws-acm-request-certificate
module "acm" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.16.0"

  certificate_authority_arn         = local.private_ca_enabled ? module.private_ca[0].outputs.private_ca[var.certificate_authority_component_key].certificate_authority.arn : null
  validation_method                 = local.private_ca_enabled ? null : var.validation_method
  domain_name                       = var.domain_name
  process_domain_validation_options = var.process_domain_validation_options
  ttl                               = 300
  subject_alternative_names         = concat([format("*.%s", var.domain_name)], var.subject_alternative_names)
  zone_id                           = join("", data.aws_route53_zone.default.*.zone_id)

  context = module.this.context
}

resource "aws_ssm_parameter" "acm_arn" {
  count = local.enabled ? 1 : 0

  name        = "/acm/${var.domain_name}"
  value       = module.acm.arn
  description = "ACM certificate id"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}
