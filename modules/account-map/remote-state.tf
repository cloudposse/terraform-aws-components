module "accounts" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.13.0"

  component               = "account"
  privileged              = true
  stack_config_local_path = "/home/user/ws/datameer/infrastructure-atmos-novel/stacks"

  context = module.this.context
}
