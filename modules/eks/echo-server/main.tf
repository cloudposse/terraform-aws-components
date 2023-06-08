locals {
  enabled               = module.this.enabled
  ingress_nginx_enabled = var.ingress_type == "nginx" ? true : false
  ingress_alb_enabled   = var.ingress_type == "alb" ? true : false
}

module "echo_server" {
  source  = "cloudposse/helm-release/aws"
  version = "0.7.0"

  name  = module.this.name
  chart = "${path.module}/charts/echo-server"

  # Optional arguments
  description     = var.description
  repository      = var.repository
  chart_version   = var.chart_version
  verify          = var.verify
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = var.create_namespace
  kubernetes_namespace             = var.kubernetes_namespace
  kubernetes_namespace_labels      = merge(module.this.tags, { name = var.kubernetes_namespace })

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  set = [
    {
      name  = "ingress.hostname"
      value = format(var.hostname_template, var.tenant, var.stage, var.environment)
      type  = "auto"
    },
    {
      name  = "ingress.nginx.enabled"
      value = local.ingress_nginx_enabled
      type  = "auto"
    },
    {
      name  = "ingress.alb.group_name"
      value = module.alb.outputs.group_name
      type  = "auto"
    },
    {
      name  = "ingress.alb.enabled"
      value = local.ingress_alb_enabled
      type  = "auto"
    },
  ]

  values = compact([
    # additional values
    try(length(var.chart_values), 0) == 0 ? null : yamlencode(var.chart_values)
  ])

  context = module.this.context
}
