module "datadog_integration" {
  source  = "cloudposse/datadog-integration/aws"
  version = "1.0.0"

  count = module.this.enabled && length(var.integrations) > 0 ? 1 : 0

  datadog_aws_account_id           = var.datadog_aws_account_id
  integrations                     = var.integrations
  filter_tags                      = local.filter_tags
  host_tags                        = local.host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules

  context = module.this.context
}

locals {
  enabled = module.this.enabled

  # Get the context tags and skip tags that we don't want applied to every resource.
  # i.e. we don't want name since each metric would be called something other than this component's name.
  # i.e. we don't want environment since each metric would come from gbl or a region and this component is deployed in gbl.
  context_tags = [for k, v in module.this.tags : "${lower(k)}:${v}" if contains(var.context_host_and_filter_tags, lower(k))]
  filter_tags  = distinct(concat(var.filter_tags, local.context_tags))
  host_tags    = distinct(concat(var.host_tags, local.context_tags))
}
