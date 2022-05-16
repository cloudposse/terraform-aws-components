module "sso" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component  = "sso"
  privileged = true

  ignore_errors = true

  defaults = {
    saml_provider_arns = []
  }

  context = module.this.context
}
