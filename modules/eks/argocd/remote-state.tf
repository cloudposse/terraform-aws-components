module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.eks_component_name

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  environment = "gbl"
  component   = "dns-delegated"

  context = module.this.context
}

module "saml_sso_providers" {
  for_each = local.enabled ? var.saml_sso_providers : {}
  source   = "cloudposse/stack-config/yaml//modules/remote-state"
  version  = "1.4.1"

  component = each.value.component

  context = module.this.context
}

module "argocd_repo" {
  for_each = local.enabled ? var.argocd_repositories : {}

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = each.key
  environment = each.value.environment
  stage       = each.value.stage
  tenant      = each.value.tenant

  context = module.this.context
}
