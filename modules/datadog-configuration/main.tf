locals {
  enabled     = module.this.enabled
  asm_enabled = local.enabled && var.datadog_secrets_store_type == "ASM"

  datadog_site    = coalesce(var.datadog_site_url, "datadoghq.com")
  datadog_api_url = format("https://api.%s", local.datadog_site)
}
