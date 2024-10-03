module "datadog-integration" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "datadog-integration"

  environment = module.iam_roles.global_environment_name
  context     = module.this.context
}
