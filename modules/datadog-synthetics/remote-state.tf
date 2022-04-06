module "datadog_synthetics_private_location" {
  count = var.private_location_test_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component = "datadog-synthetics-private-location"
  context = module.this.context
}
