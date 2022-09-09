locals {
  enabled = module.this.enabled
}

module "argocd_applicationset" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  name                 = "" # avoids hitting length restrictions on IAM Role names
  chart                = var.chart
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled = false

  values = compact([
    # standard k8s object settings
    yamlencode({
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.introspection.context
}
