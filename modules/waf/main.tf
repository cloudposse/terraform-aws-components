locals {
  enabled = module.this.enabled

  association_resource_component_selectors_arns = [
    for i, v in var.association_resource_component_selectors : module.association_resource_components[i].outputs[v.component_arn_output]
  ]

  association_resource_arns = concat(var.association_resource_arns, local.association_resource_component_selectors_arns)
}

module "aws_waf" {
  source  = "cloudposse/waf/aws"
  version = "1.0.0"

  description             = var.description
  default_action          = var.default_action
  custom_response_body    = var.custom_response_body
  scope                   = var.scope
  visibility_config       = var.visibility_config
  token_domains           = var.token_domains
  log_destination_configs = var.log_destination_configs
  redacted_fields         = var.redacted_fields
  logging_filter          = var.logging_filter

  association_resource_arns = local.association_resource_arns

  # Rules
  byte_match_statement_rules                  = var.byte_match_statement_rules
  geo_allowlist_statement_rules               = var.geo_allowlist_statement_rules
  geo_match_statement_rules                   = var.geo_match_statement_rules
  ip_set_reference_statement_rules            = var.ip_set_reference_statement_rules
  managed_rule_group_statement_rules          = var.managed_rule_group_statement_rules
  rate_based_statement_rules                  = var.rate_based_statement_rules
  regex_pattern_set_reference_statement_rules = var.regex_pattern_set_reference_statement_rules
  regex_match_statement_rules                 = var.regex_match_statement_rules
  rule_group_reference_statement_rules        = var.rule_group_reference_statement_rules
  size_constraint_statement_rules             = var.size_constraint_statement_rules
  sqli_match_statement_rules                  = var.sqli_match_statement_rules
  xss_match_statement_rules                   = var.xss_match_statement_rules

  context = module.this.context
}

resource "aws_ssm_parameter" "acl_arn" {
  count = local.enabled ? 1 : 0

  name        = "${var.ssm_path_prefix}/${var.acl_name}/arn"
  value       = module.aws_waf.arn
  description = "ARN for WAF web ACL ${var.acl_name}"
  type        = "String"
  overwrite   = true
  tags        = module.this.tags
}
