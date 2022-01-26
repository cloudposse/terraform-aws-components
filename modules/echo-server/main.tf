locals {
  enabled               = module.this.enabled
  ingress_nginx_enabled = var.ingress_type == "nginx" ? true : false
  ingress_alb_enabled   = var.ingress_type == "alb" ? true : false
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

  # NOTE: Use with the local chart
  set {
    name  = "ingress.hostname"
    value = format(var.hostname_template, var.stage, var.environment)
  }
  set {
    name  = "ingress.nginx.enabled"
    value = local.ingress_nginx_enabled
  }
  set {
    name  = "ingress.alb.enabled"
    value = local.ingress_alb_enabled
  }
}
