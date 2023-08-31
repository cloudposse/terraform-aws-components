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
  version = "1.3.0"
}

locals {
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
  version = "1.5.0"

  component = "datadog-configuration"

  environment = var.global_environment_name
  context     = module.always.context
}

data "aws_ssm_parameter" "datadog_api_key" {
  count = module.this.enabled ? 1 : 0

  provider = aws.dd_api_keys

  name = module.datadog_configuration.outputs.datadog_api_key_location
}

data "aws_ssm_parameter" "datadog_app_key" {
  count = module.this.enabled ? 1 : 0

  provider = aws.dd_api_keys

  name = module.datadog_configuration.outputs.datadog_app_key_location
}
