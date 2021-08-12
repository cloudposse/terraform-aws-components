module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.18.3"

  stack_config_local_path = "../../../stacks"
  component               = "account-map"
  environment             = "gbl"
  stage                   = "root"

  context = module.this.context
}
