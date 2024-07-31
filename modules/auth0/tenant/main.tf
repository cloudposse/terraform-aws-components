locals {
  enabled = module.this.enabled

  name        = length(module.this.name) > 0 ? module.this.name : "auth0"
  domain_name = format("%s.%s", local.name, module.dns_gbl_delegated.outputs.default_domain_name)

  friendly_name = length(var.friendly_name) > 0 ? var.friendly_name : module.this.id
}

# Chicken before the egg...
#
# The tenant must exist before we can manage Auth0 with Terraform,
# but the tenant is not a resource identifiable by an ID within the Auth0 Management API!
#
# However, we can import it using a random string. On first run, we import the existing tenant
# using a random string. It does not matter what this value is. Terraform will use the same
# tenant as the Auth0 application for the Terraform Auth0 Provider.
#
# https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/tenant#import
import {
  to = auth0_tenant.this[0]
  id = "f6615002-81ff-49f7-afd3-8814d07af4fa"
}

resource "auth0_tenant" "this" {
  count = local.enabled ? 1 : 0

  friendly_name = local.friendly_name
  picture_url   = var.picture_url
  support_email = var.support_email
  support_url   = var.support_url

  allowed_logout_urls     = var.allowed_logout_urls
  idle_session_lifetime   = var.idle_session_lifetime
  session_lifetime        = var.session_lifetime
  sandbox_version         = var.sandbox_version
  enabled_locales         = var.enabled_locales
  default_redirection_uri = var.default_redirection_uri

  flags {
    disable_clickjack_protection_headers   = var.disable_clickjack_protection_headers
    enable_public_signup_user_exists_error = var.enable_public_signup_user_exists_error
    use_scope_descriptions_for_consent     = var.use_scope_descriptions_for_consent
    no_disclose_enterprise_connections     = var.no_disclose_enterprise_connections
    disable_management_api_sms_obfuscation = var.disable_management_api_sms_obfuscation
    disable_fields_map_fix                 = var.disable_fields_map_fix
  }

  session_cookie {
    mode = var.session_cookie_mode
  }

  sessions {
    oidc_logout_prompt_enabled = var.oidc_logout_prompt_enabled
  }
}

resource "auth0_custom_domain" "this" {
  count = local.enabled ? 1 : 0

  domain = local.domain_name
  type   = "auth0_managed_certs"
}

resource "aws_route53_record" "this" {
  count = local.enabled ? 1 : 0

  zone_id = module.dns_gbl_delegated.outputs.default_dns_zone_id
  name    = local.domain_name
  type    = upper(auth0_custom_domain.this[0].verification[0].methods[0].name)
  ttl     = "300"
  records = [
    auth0_custom_domain.this[0].verification[0].methods[0].record,
  ]
}

resource "auth0_custom_domain_verification" "this" {
  count = local.enabled ? 1 : 0

  custom_domain_id = auth0_custom_domain.this[0].id

  timeouts {
    create = "15m"
  }

  depends_on = [
    aws_route53_record.this,
  ]
}
