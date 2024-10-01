module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.eks_component_name

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "dns-delegated"
  environment = var.dns_gbl_delegated_environment_name

  context = module.this.context

  defaults = {
    zones = {}
  }
}

module "dns_gbl_primary" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "dns-primary"
  environment = var.dns_gbl_primary_environment_name

  context = module.this.context

  ignore_errors = true

  defaults = {
    zones = {}
  }
}

module "additional_dns_components" {
  for_each = { for obj in var.dns_components : obj.component => obj }
  source   = "cloudposse/stack-config/yaml//modules/remote-state"
  version  = "1.5.0"

  component   = each.value.component
  environment = coalesce(each.value.environment, "gbl")

  context = module.this.context
}
