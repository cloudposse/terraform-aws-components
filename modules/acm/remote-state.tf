module "private_ca" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.private_ca_enabled ? 1 : 0

  component   = var.certificate_authority_component_name
  stage       = var.certificate_authority_stage_name
  environment = var.certificate_authority_environment_name

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.dns_delegated_component_name
  stage       = var.dns_delegated_stage_name
  environment = var.dns_delegated_environment_name

  context = module.this.context
}
