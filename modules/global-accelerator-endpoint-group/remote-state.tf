module "global_accelerator" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "global-accelerator"
  environment = var.global_accelerator_environment_name

  context = module.this.context
}
