module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  stack_config_local_path = "../../../stacks"
  stack                   = var.vpc_stack_name
  component               = "vpc"

  context = module.this.context
}

module "bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  stack_config_local_path = "../../../stacks"
  component               = "sftp-bucket"

  context = module.this.context
}
