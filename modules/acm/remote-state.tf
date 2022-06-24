module "private_ca" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  count = local.private_ca_enabled ? 1 : 0

  component   = var.certificate_authority_component_name
  stage       = var.certificate_authority_stage_name
  environment = var.certificate_authority_environment_name

  context = module.this.context
}
