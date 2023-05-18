module "datadog_configuration" {
  source  = "../datadog-configuration/modules/datadog_keys"
  context = module.this.context
  enabled = true
}

provider "datadog" {
  api_key  = module.datadog_configuration.datadog_api_key
  app_key  = module.datadog_configuration.datadog_app_key
  api_url  = module.datadog_configuration.datadog_api_url
  validate = local.enabled
}
