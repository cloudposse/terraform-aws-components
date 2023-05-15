module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.vpc_component_name

  context = module.this.context
}

module "logs_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.logs_bucket_component_name

  bypass        = !local.query_log_enabled || var.logs_bucket_component_name == null || var.logs_bucket_component_name == ""
  ignore_errors = !local.query_log_enabled || var.logs_bucket_component_name == null || var.logs_bucket_component_name == ""

  defaults = {
    bucket_id  = ""
    bucket_arn = ""
  }

  context = module.this.context
}
