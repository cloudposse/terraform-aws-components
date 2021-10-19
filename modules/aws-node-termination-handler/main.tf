locals {
  enabled = module.this.enabled
}

module "aws_node_termination_handler" {
  source  = "cloudposse/helm-release/aws"
  version = "0.2.0"

  name                 = module.this.name
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
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
