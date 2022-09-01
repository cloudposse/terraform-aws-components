module "datadog_integration" {
  source  = "cloudposse/datadog-integration/aws"
  version = "0.18.0"

  datadog_aws_account_id           = var.datadog_aws_account_id
  integrations                     = var.integrations
  filter_tags                      = local.filter_tags
  host_tags                        = local.host_tags
  excluded_regions                 = var.excluded_regions
  account_specific_namespace_rules = var.account_specific_namespace_rules

  context = module.this.context
}

locals {
  enabled     = module.this.enabled
  asm_enabled = local.enabled && var.datadog_secrets_store_type == "ASM"
  ssm_enabled = local.enabled && var.datadog_secrets_store_type == "SSM"

  # https://docs.datadoghq.com/account_management/api-app-keys/
  datadog_api_key = local.enabled ? (local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string : data.aws_ssm_parameter.datadog_api_key[0].value) : null
  datadog_app_key = local.enabled ? (local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_app_key[0].secret_string : data.aws_ssm_parameter.datadog_app_key[0].value) : null

  # Get the context tags and skip tags that we don't want applied to every resource.
  # i.e. we don't want name since each metric would be called something other than this component's name.
  # i.e. we don't want environment since each metric would come from gbl or a region and this component is deployed in gbl.
  context_tags = [for k, v in module.this.tags : "${lower(k)}:${v}" if contains(var.context_host_and_filter_tags, lower(k))]
  filter_tags  = distinct(concat(var.filter_tags, local.context_tags))
  host_tags    = distinct(concat(var.host_tags, local.context_tags))
}
