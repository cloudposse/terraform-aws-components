module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.vpc_component_name

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component   = var.dns_delegated_component_name
  environment = coalesce(var.dns_delegated_environment_name, module.iam_roles.global_environment_name)

  bypass = var.dns_acm_enabled

  # Ignore errors if component doesn't exist
  ignore_errors = true

  defaults = {
    default_domain_name = ""
    certificate         = {}
  }

  context = module.this.context
}

module "acm" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.acm_component_name

  bypass = !var.dns_acm_enabled

  # Ignore errors if component doesn't exist
  ignore_errors = true

  defaults = {
    arn = ""
  }

  context = module.this.context
}
