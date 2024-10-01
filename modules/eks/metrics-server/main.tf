locals {
  enabled = module.this.enabled
}

moved {
  from = kubernetes_namespace.default
  to   = module.metrics_server.kubernetes_namespace.default
}

module "metrics_server" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name            = "" # avoids hitting length restrictions on IAM Role names
  chart           = var.chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  kubernetes_namespace             = var.kubernetes_namespace
  create_namespace_with_kubernetes = var.create_namespace

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
        chart = var.chart
        # TODO: These should be configurable
        # Chart should default to https://kubernetes-sigs.github.io/metrics-server/
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
