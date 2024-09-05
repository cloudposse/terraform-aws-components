locals {
  enabled = module.this.enabled

  ssm_path               = coalesce(var.provider_ssm_base_path, module.this.id)
  client_id_ssm_path     = format("/%s/client_id", local.ssm_path)
  client_secret_ssm_path = format("/%s/client_secret", local.ssm_path)
}

resource "auth0_client" "this" {
  count = local.enabled ? 1 : 0

  name = module.this.id

  app_type        = var.app_type
  oidc_conformant = var.oidc_conformant
  sso             = var.sso

  jwt_configuration {
    lifetime_in_seconds = var.jwt_lifetime_in_seconds
    alg                 = var.jwt_alg
  }

  callbacks       = var.callbacks
  allowed_origins = var.allowed_origins
  web_origins     = var.web_origins
  grant_types     = var.grant_types
  logo_uri        = var.logo_uri

}

resource "auth0_client_credentials" "this" {
  count = local.enabled ? 1 : 0

  client_id             = try(auth0_client.this[0].client_id, "")
  authentication_method = var.authentication_method
}

module "auth0_ssm_parameters" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  enabled = local.enabled

  parameter_write = [
    {
      name        = local.client_id_ssm_path
      value       = try(auth0_client.this[0].client_id, "")
      type        = "SecureString"
      overwrite   = "true"
      description = "Auth0 client ID for the Auth0 ${module.this.id} application"
    },
    {
      name        = local.client_secret_ssm_path
      value       = try(auth0_client_credentials.this[0].client_secret, "")
      type        = "SecureString"
      overwrite   = "true"
      description = "Auth0 client secret for the Auth0 ${module.this.id} application"
    }
  ]

  context = module.this.context
}
