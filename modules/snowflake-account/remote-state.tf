module "account" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component   = "account"
  stage       = var.root_account_stage_name
  environment = var.global_environment_name
  privileged  = var.privileged

  context = module.introspection.context
}
