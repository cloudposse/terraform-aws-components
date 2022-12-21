module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # datadog configuration must always be enabled, even for components that are disabled
  # this allows datadog provider to be configured correctly and properly delete resources.
  enabled = true

  context = module.this.context
}

module "utils_example_complete" {
  source  = "cloudposse/utils/aws"
  version = "1.1.0"
}

locals {
  # if we are in the global region, use the
  environment = module.this.environment == var.global_environment_name ? module.utils_example_complete.region_az_alt_code_maps[var.region_abbreviation_type][var.region] : var.environment

  context_tags = {
    for k, v in module.this.tags :
    lower(k) => v
  }
  dd_tags = [
    for k, v in local.context_tags :
    v != null ? format("%s:%s", k, v) : k
  ]
}
module "datadog_configuration" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component = "datadog-configuration"

  environment = local.environment
  context     = module.always.context
}

data "aws_ssm_parameter" "datadog_api_key" {
  count = module.this.enabled ? 1 : 0

  name = module.datadog_configuration.outputs.datadog_api_key_location
}

data "aws_ssm_parameter" "datadog_app_key" {
  count = module.this.enabled ? 1 : 0

  name = module.datadog_configuration.outputs.datadog_app_key_location
}
