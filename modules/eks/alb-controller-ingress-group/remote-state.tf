module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.dns_delegated_component_name
  environment = var.dns_delegated_environment_name

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.eks_component_name

  context = module.this.context
}

module "global_accelerator" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.global_accelerator_enabled ? toset(["true"]) : []

  component   = var.global_accelerator_component_name
  environment = "gbl"

  context = module.this.context
}

module "waf" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.waf_enabled ? toset(["true"]) : []

  component = var.waf_component_name

  context = module.this.context
}
