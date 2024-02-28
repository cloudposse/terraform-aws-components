# https://karpenter.sh/v0.34/getting-started/getting-started-with-karpenter/

locals {
  enabled = module.this.enabled

  eks_cluster_identity_oidc_issuer   = try(module.eks.outputs.eks_cluster_identity_oidc_issuer, "")
  karpenter_iam_role_arn             = try(module.eks.outputs.karpenter_iam_role_arn, "")
  karpenter_iam_role_name            = try(module.eks.outputs.karpenter_iam_role_name, "")
  karpenter_instance_profile_enabled = local.enabled && var.legacy_create_karpenter_instance_profile && length(local.karpenter_iam_role_name) > 0

  kubernetes_namespace = coalesce(join("", kubernetes_namespace.default[*].id), var.kubernetes_namespace)
}


resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name        = var.kubernetes_namespace
    annotations = {}
    labels      = merge(module.this.tags, { name = var.kubernetes_namespace })
  }
}

# Deploy karpenter-crd helm chart
# karpenter-crd can be installed as an independent helm chart to manage the lifecycle of Karpenter CRDs
module "karpenter_crd" {
  enabled = local.enabled && var.crd_chart_enabled

  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name            = var.crd_chart
  chart           = var.crd_chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = false # Namespace is created with kubernetes_namespace resources to be shared between charts
  kubernetes_namespace             = local.kubernetes_namespace
  kubernetes_namespace_labels      = merge(module.this.tags, { name = local.kubernetes_namespace })

  eks_cluster_oidc_issuer_url = coalesce(replace(local.eks_cluster_identity_oidc_issuer, "https://", ""), "deleted")

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name
      resources        = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
  ])

  context = module.this.context

  depends_on = [
    kubernetes_namespace.default
  ]
}

# Deploy Karpenter helm chart
module "karpenter" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  chart           = var.chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = false # Namespace is created with kubernetes_namespace resources to be shared between charts
  kubernetes_namespace             = local.kubernetes_namespace
  kubernetes_namespace_labels      = merge(module.this.tags, { name = local.kubernetes_namespace })

  eks_cluster_oidc_issuer_url = coalesce(replace(local.eks_cluster_identity_oidc_issuer, "https://", ""), "deleted")

  service_account_name      = module.this.name
  service_account_namespace = local.kubernetes_namespace

  iam_role_enabled = true
  iam_policy       = [{ statements = local.controller_policy_statements }]

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name
      serviceAccount = {
        name = module.this.name
      }
      controller = {
        resources = var.resources
      }
      rbac = {
        create = var.rbac_enabled
      }
    }),
    yamlencode({
      dnsPolicy = "Default" # required if karpenter must be deployed before dns service (CoreDNS) is available; override via chart_values variable if needed
      settings = {
        clusterName = local.eks_cluster_id
      }
    }),
    yamlencode(
      local.interruption_handler_enabled ? {
        settings = {
          interruptionQueue = local.interruption_handler_queue_name
        }
    } : {}),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context

  depends_on = [
    aws_iam_instance_profile.default,
    module.karpenter_crd,
    kubernetes_namespace.default
  ]
}
