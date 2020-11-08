module "datadog_integration" {
  source = "git::https://github.com/cloudposse/terraform-aws-datadog-integration.git?ref=tags/0.6.1"

  datadog_aws_account_id           = var.datadog_aws_account_id
  integrations                     = var.integrations
  filter_tags                      = var.filter_tags
  host_tags                        = var.host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules

  context = module.this.context
}
