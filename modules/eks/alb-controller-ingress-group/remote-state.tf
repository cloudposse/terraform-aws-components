module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component   = "dns-delegated"
  environment = var.dns_delegated_environment_name

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.eks_component_name

  context = module.this.context
}

module "global_accelerator" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  for_each = local.global_accelerator_enabled ? toset(["true"]) : []

  component   = "global-accelerator"
  environment = "gbl"

  context = module.this.context
}

module "waf" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  for_each = local.waf_enabled ? toset(["true"]) : []

  component = "waf"

  context = module.this.context
}
