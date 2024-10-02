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

module "efs_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.9.1"

  name                 = var.name
  chart                = var.chart
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  create_namespace     = false
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  # creates acme-<env>-<stage>-efs-controller-all@all
  iam_role_enabled = true
  iam_policy_statements = yamldecode(
    file("${path.module}/resources/iam_policy_statements.yaml")
  )

  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/helm-chart-aws-efs-csi-driver-2.2.7/charts/aws-efs-csi-driver/values.yaml#L77
  # https://github.com/cloudposse/terraform-aws-helm-release/blob/master/variables.tf#L77
  service_account_set_key_path = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  eks_cluster_oidc_issuer_url  = module.eks.outputs.eks_cluster_identity_oidc_issuer

  values = compact([
    # hardcoded values
    yamlencode(yamldecode(file("${path.module}/resources/values.yaml"))),
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      storageClasses = [{
        name = "efs-sc"
        # annotations:
        #   storageclass.kubernetes.io/is-default-class: "true"
        parameters = {
          fileSystemId     = local.enabled ? module.efs.outputs.efs_id : ""
          provisioningMode = "efs-ap"
          directoryPerms   = "700"
          basePath         = "/efs_controller"
        },
        reclaimPolicy     = "Delete"
        volumeBindingMode = "Immediate"
      }],
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
