locals {
  enabled = module.this.enabled
}

module "idp_roles" {
  source  = "cloudposse/helm-release/aws"
  version = "0.2.1"

  # Required arguments
  name                 = module.this.name
  chart                = "${path.module}/charts/${var.chart}"
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

  context = module.this.context
}
