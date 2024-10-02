locals {
  enabled = module.this.enabled

  sub_domain = var.name
  root_domain = coalesce(module.acm.outputs.domain_name, join(".", [
    module.this.environment, module.dns_delegated.outputs.default_domain_name
  ]), module.dns_delegated.outputs.default_domain_name)
  domain_name = join(".", [local.sub_domain, local.root_domain])
}

module "api_gateway_rest_api" {
  source  = "cloudposse/api-gateway/aws"
  version = "0.3.1"

  enabled = local.enabled

  openapi_config           = var.openapi_config
  endpoint_type            = var.endpoint_type
  logging_level            = var.logging_level
  metrics_enabled          = var.metrics_enabled
  xray_tracing_enabled     = var.xray_tracing_enabled
  access_log_format        = var.access_log_format
  rest_api_policy          = var.rest_api_policy
  private_link_target_arns = module.nlb[*].nlb_arn

  context = module.this.context
}

data "aws_acm_certificate" "issued" {
  count    = local.enabled ? 1 : 0
  domain   = local.root_domain
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "this" {
  count        = local.enabled ? 1 : 0
  name         = module.dns_delegated.outputs.default_domain_name
  private_zone = false
}

resource "aws_api_gateway_domain_name" "this" {
  count                    = local.enabled ? 1 : 0
  domain_name              = local.domain_name
  regional_certificate_arn = data.aws_acm_certificate.issued[0].arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = module.this.tags
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count       = local.enabled ? 1 : 0
  api_id      = module.api_gateway_rest_api.id
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
  stage_name  = module.this.stage

  depends_on = [
    aws_api_gateway_domain_name.this,
    module.api_gateway_rest_api
  ]

}

resource "aws_route53_record" "this" {
  count   = local.enabled ? 1 : 0
  name    = aws_api_gateway_domain_name.this[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.this[0].id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this[0].regional_zone_id
  }
}
