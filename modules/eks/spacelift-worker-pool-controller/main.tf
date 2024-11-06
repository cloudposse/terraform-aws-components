# https://docs.spacelift.io/concepts/worker-pools#kubernetes
# https://docs.spacelift.io/integrations/docker#customizing-the-runner-image

locals {
  enabled = module.this.enabled

  kubernetes_labels = { for k, v in merge(module.this.tags, { name = var.kubernetes_namespace }) : k => replace(v, "/", "_") if local.enabled }
}

# Deploy Spacelift worker pool Kubernetes controller Helm chart
# https://docs.spacelift.io/concepts/worker-pools#installation
# https://github.com/spacelift-io/spacelift-helm-charts/tree/main/spacelift-workerpool-controller
# https://github.com/spacelift-io/spacelift-helm-charts/blob/main/spacelift-workerpool-controller/values.yaml
module "spacelift_worker_pool_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  chart         = var.chart
  repository    = var.chart_repository
  chart_version = var.chart_version
  description   = var.chart_description

  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = var.create_namespace_with_kubernetes
  kubernetes_namespace             = var.kubernetes_namespace
  kubernetes_namespace_labels      = local.kubernetes_labels

  # eks_cluster_oidc_issuer_url is only needed when iam_role_enabled is true,
  # but unfortunately the module requires a non-empty value.
  eks_cluster_oidc_issuer_url = "not-needed"

  iam_role_enabled = false

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name
    }),

    yamlencode(
      {
        controllerManager = {
          namespaces = [
            var.kubernetes_namespace
          ]
        }
      }
    ),

    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
