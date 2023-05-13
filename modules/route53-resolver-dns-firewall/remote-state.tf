module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.vpc_component_name

  context = module.this.context
}

module "logs_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  count = !local.query_log_enabled || var.logs_bucket_component_name == null || var.logs_bucket_component_name == "" ? 0 : 1

  component = var.logs_bucket_component_name

  context = module.this.context
}
