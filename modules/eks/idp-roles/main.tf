locals {
  enabled = module.this.enabled
}

module "idp_roles" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  # Required arguments
  name                 = module.this.name
  chart                = "${path.module}/charts/idp-roles"
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  verify               = var.verify
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout
  values               = [yamlencode(var.chart_values)]

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  context = module.this.context
}
