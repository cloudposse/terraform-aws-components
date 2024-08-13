locals {
  enabled = module.this.enabled
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
