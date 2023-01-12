module "datadog_configuration" {
  source  = "../datadog-configuration/modules/datadog_keys"
  region  = var.region
  context = module.this.context
}

locals {
  datadog_api_key = module.datadog_configuration.datadog_api_key
  datadog_app_key = module.datadog_configuration.datadog_app_key
}
