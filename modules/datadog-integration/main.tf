locals {
  use_include_regions      = length(var.included_regions) > 0
  all_regions              = data.aws_regions.all.names
  excluded_list_by_include = setsubtract(local.use_include_regions ? local.all_regions : [], var.included_regions)
}

data "aws_regions" "all" {
  all_regions = true
}

module "datadog_integration" {
  source  = "cloudposse/datadog-integration/aws"
  version = "1.2.0"

  enabled = module.this.enabled && length(var.integrations) > 0

  datadog_aws_account_id           = var.datadog_aws_account_id
  integrations                     = var.integrations
  filter_tags                      = local.filter_tags
  host_tags                        = local.host_tags
  excluded_regions                 = concat(var.excluded_regions, tolist(local.excluded_list_by_include))
  account_specific_namespace_rules = var.account_specific_namespace_rules
  cspm_resource_collection_enabled = var.cspm_resource_collection_enabled
  metrics_collection_enabled       = var.metrics_collection_enabled
  resource_collection_enabled      = var.resource_collection_enabled

  context = module.this.context
}

locals {
  enabled = module.this.enabled

  # Get the context tags and skip tags that we don't want applied to every resource.
  # i.e. we don't want name since each metric would be called something other than this component's name.
  # i.e. we don't want environment since each metric would come from gbl or a region and this component is deployed in gbl.
  context_tags = [
    for k, v in module.this.tags : "${lower(k)}:${v}" if contains(var.context_host_and_filter_tags, lower(k))
  ]
  filter_tags = distinct(concat(var.filter_tags, local.context_tags))
  host_tags   = distinct(concat(var.host_tags, local.context_tags))
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.11.0"

  parameter_write = [
    {
      name        = "/datadog/datadog_external_id"
      value       = join("", module.datadog_integration[*].datadog_external_id)
      type        = "String"
      overwrite   = "true"
      description = "External identifier for our dd integration"
    },
    {
      name        = "/datadog/aws_role_name"
      value       = join("", module.datadog_integration[*].aws_role_name)
      type        = "String"
      overwrite   = "true"
      description = "Name of the AWS IAM role used by our dd integration"
    }
  ]

  context = module.this.context
}
