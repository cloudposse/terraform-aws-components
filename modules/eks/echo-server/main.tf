locals {
  enabled               = module.this.enabled
  ingress_nginx_enabled = var.ingress_type == "nginx" ? true : false
  ingress_alb_enabled   = var.ingress_type == "alb" ? true : false

  alb_access_logs_enabled = var.alb_access_logs_enabled && var.alb_access_logs_s3_bucket_name != null && var.alb_access_logs_s3_bucket_name != ""
  ingress_controller_group_enabled = var.alb_controller_ingress_group_enabled ? [
    {
      name  = "ingress.alb.group_name"
      value = module.alb_controller_ingress_group.outputs.group_name
      type  = "auto"
    }
  ] : []
}

resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = module.this.tags
  }
}

module "echo_server" {
  source  = "cloudposse/helm-release/aws"
  version = "0.5.0"

  name  = module.this.name
  chart = "${path.module}/charts/echo-server"

  # Optional arguments
  description          = var.description
  repository           = var.repository
  chart_version        = var.chart_version
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  create_namespace     = false
  verify               = var.verify
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  set = concat([
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
      name  = "ingress.alb.enabled"
      value = local.ingress_alb_enabled
      type  = "auto"
    },
    {
      name  = "ingress.alb.access_logs.enabled"
      value = local.alb_access_logs_enabled
      type  = "auto"
    },
    {
      name  = "ingress.alb.access_logs.s3_bucket_name"
      value = var.alb_access_logs_s3_bucket_name == null ? "" : var.alb_access_logs_s3_bucket_name
      type  = "auto"
    },
    {
      name  = "ingress.alb.access_logs.s3_bucket_prefix"
      value = var.alb_access_logs_s3_bucket_prefix
      type  = "auto"
    }
    ],
    local.ingress_controller_group_enabled
  )

  values = compact([
    # hardcoded values
    file("${path.module}/values.yaml"),
  ])

  context = module.this.context
}

