locals {
  enabled = module.this.enabled
}

resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = module.this.tags
  }
}

module "metrics_server" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  name                 = "" # avoids hitting length restrictions on IAM Role names
  chart                = var.chart
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  create_namespace     = false
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # hardcoded values
    file("${path.module}/resources/values.yaml"),
    # metrics-server-specific values
    yamlencode({
      podLabels = merge({
        chart     = var.chart
        repo      = "bitnami"
        component = "hpa"
        namespace = var.kubernetes_namespace
        vendor    = "kubernetes"
        },
      module.this.tags)
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
