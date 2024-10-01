module "prometheus" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.enabled ? {
    for target in var.prometheus_source_accounts : "${target.tenant}:${target.stage}:${target.environment}" => target
  } : {}

  component   = each.value.component
  stage       = each.value.stage
  environment = length(each.value.environment) > 0 ? each.value.environment : module.this.environment
  tenant      = length(each.value.tenant) > 0 ? each.value.tenant : module.this.tenant

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}
