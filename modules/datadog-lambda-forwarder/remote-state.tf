module "datadog-integration" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component = "datadog-integration"

  environment = "gbl"
  context     = module.this.context
}
