module "datadog_synthetics_private_location" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.synthetics_private_location_component_name

  bypass        = !local.enabled || !var.private_location_test_enabled
  ignore_errors = !var.private_location_test_enabled

  defaults = {
    synthetics_private_location_id = ""
  }

  context = module.this.context
}
