module "datadog_configuration" {
  source  = "../datadog-configuration/modules/datadog_keys"
  enabled = true
  context = module.this.context
}

locals {
  datadog_api_key = module.datadog_configuration.datadog_api_key
  datadog_app_key = module.datadog_configuration.datadog_app_key
}

provider "datadog" {
  api_key  = local.datadog_api_key
  app_key  = local.datadog_app_key
  api_url  = module.datadog_configuration.datadog_api_url
  validate = local.enabled
}
