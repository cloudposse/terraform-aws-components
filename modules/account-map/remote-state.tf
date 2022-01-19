module "accounts" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  component               = "account"
  privileged              = true
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}
