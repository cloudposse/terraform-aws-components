module "datadog-integration" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "datadog-integration"

  environment = "gbl"
  context     = module.this.context
}
