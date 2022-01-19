locals {
  enabled = module.this.enabled
}

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  # Required arguments
  name  = module.this.name
  chart = "${path.module}/charts/echo-server"

  # Optional arguments
  description      = var.description
  repository       = var.repository
  version          = var.chart_version
  namespace        = var.kubernetes_namespace
  create_namespace = var.create_namespace
  verify           = var.verify
  wait             = var.wait
  atomic           = var.atomic
  cleanup_on_fail  = var.cleanup_on_fail
  timeout          = var.timeout

  values = [
    yamlencode({
      host = format(var.hostname_template, var.environment, var.stage),
      ingress = {
        target_hostname = module.ingress_nginx.outputs.ingress_nginx_hostname
      }
    }),
    yamlencode(var.chart_values)
  ]
}
