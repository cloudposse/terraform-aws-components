module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.private_enabled ? local.vpc_environment_names : toset([])

  component   = "vpc"
  environment = each.value

  context = module.this.context
}

module "private_ca" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.private_ca_enabled && local.certificate_enabled ? 1 : 0

  component   = var.certificate_authority_component_name
  stage       = var.certificate_authority_stage_name
  environment = var.certificate_authority_environment_name

  context = module.this.context
}
