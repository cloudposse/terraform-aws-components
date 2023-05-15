locals {
  enabled           = module.this.enabled
  query_log_enabled = local.enabled && var.query_log_enabled

  vpc_outputs = module.vpc.outputs
  vpc_id      = local.vpc_outputs.vpc_id

  logs_bucket_outputs = module.logs_bucket.outputs
  logs_bucket_arn     = local.logs_bucket_outputs.bucket_arn
}

module "route53_resolver_dns_firewall" {
  source  = "cloudposse/route53-resolver-dns-firewall/aws"
  version = "0.2.1"

  vpc_id                    = local.vpc_id
  query_log_destination_arn = local.logs_bucket_arn
  query_log_enabled         = local.query_log_enabled
  firewall_fail_open        = var.firewall_fail_open
  query_log_config_name     = var.query_log_config_name
  domains_config            = var.domains_config
  rule_groups_config        = var.rule_groups_config

  context = module.this.context
}
