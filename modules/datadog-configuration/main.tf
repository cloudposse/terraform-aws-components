locals {
  enabled     = module.this.enabled
  asm_enabled = local.enabled && var.datadog_secrets_store_type == "ASM"
  ssm_enabled = local.enabled && var.datadog_secrets_store_type == "SSM"

  # https://docs.datadoghq.com/account_management/api-app-keys/
  datadog_api_key = local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string : local.ssm_enabled ? data.aws_ssm_parameter.datadog_api_key[0].value : ""
  datadog_app_key = local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_app_key[0].secret_string : local.ssm_enabled ? data.aws_ssm_parameter.datadog_app_key[0].value : ""

  datadog_site    = coalesce(var.datadog_site_url, "datadoghq.com")
  datadog_api_url = format("https://api.%s", local.datadog_site)
}
