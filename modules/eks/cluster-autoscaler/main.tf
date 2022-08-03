locals {
  enabled = module.this.enabled
}

resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = module.introspection.tags
  }
}

module "cluster_autoscaler" {
  source  = "cloudposse/helm-release/aws"
  version = "0.4.3"

  name                 = "" # avoids hitting length restrictions on IAM Role names
  chart                = var.chart
  description          = var.description
  repository           = var.repository
  chart_version        = var.chart_version
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout
  create_namespace     = false
  verify               = var.verify

  iam_role_enabled            = true
  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")
  service_account_name        = var.service_account_name
  service_account_namespace   = var.service_account_namespace
  iam_policy_statements = yamldecode(
    file("${path.module}/resources/iam_policy_statements.yaml")
  )

  service_account_set_key_path = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"

  values = compact([
    # hardcoded values
    yamlencode(yamldecode(file("${path.module}/resources/values.yaml"))),
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      awsRegion        = var.region
      autoDiscovery = {
        clusterName = module.eks.outputs.eks_cluster_id
      }
      rbac = {
        serviceAccount = {
          name = var.service_account_name
        }
      }
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.introspection.context
}
