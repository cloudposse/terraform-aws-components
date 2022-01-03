module "global_accelerator" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.19.0"

  component               = "global-accelerator"
  environment             = var.global_accelerator_environment_name
  stack_config_local_path = "../../../stacks"

  context = module.this.context
}
