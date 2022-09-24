module "aws_saml" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.0.0"

  component  = "aws-saml"
  privileged = true

  ignore_errors = true

  defaults = {
    saml_provider_assume_role_policy = ""
  }

  context = module.this.context
}
