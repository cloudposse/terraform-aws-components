module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component = "eks"

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  environment = "gbl"
  component   = "dns-delegated"

  context = module.this.context
}

module "okta_saml_apps" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component = "okta-saml-apps"

  context = module.this.context
}

module "argocd_repo" {
  for_each = local.enabled ? var.argocd_repositories : {}

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component   = each.key
  environment = each.value.environment
  stage       = each.value.stage
  tenant      = each.value.tenant

  context = module.this.context
}
