locals {
  enabled = module.this.enabled
}

module "argocd_notifications" {
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
    # argocd-notifications specific settings
    templatefile("${path.module}/resources/argocd-notifications-values.yaml",
      {
        # value of 'hostname' intentionally not surrounded in try() block (this component has a hard dependency on the 'argocd' component)
        hostname                      = trimsuffix(jsondecode(module.argocd.outputs.metadata[0].values).server.config.url, "/")
        notifications_templates       = var.notifications_templates
        notifications_triggers        = var.notifications_triggers
        slack_notifications_enabled   = var.slack_notifications_enabled
        slack_notifications_username  = var.slack_notifications_username
        slack_notifications_icon      = var.slack_notifications_icon
        github_notifications_enabled  = var.github_notifications_enabled
        datadog_notifications_enabled = var.datadog_notifications_enabled
      }
    ),
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
