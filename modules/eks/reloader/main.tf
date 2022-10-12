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

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  name             = module.this.name
  chart            = var.chart
  repository       = var.repository
  version          = var.chart_version
  namespace        = join("", kubernetes_namespace.default.*.id)
  create_namespace = false
  wait             = var.wait
  atomic           = var.atomic
  cleanup_on_fail  = var.cleanup_on_fail
  timeout          = var.timeout
  values           = [yamlencode(var.values)]
}
