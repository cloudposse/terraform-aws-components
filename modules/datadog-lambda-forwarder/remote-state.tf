module "datadog-integration" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "datadog-integration"

  environment = "gbl"
  context     = module.this.context
}
