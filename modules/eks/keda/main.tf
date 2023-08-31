module "keda" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  name        = module.this.name
  description = var.description

  repository      = var.repository
  chart           = var.chart
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled      = false
  iam_policy_statements = {}

  values = compact([
    yamlencode({
      serviceAccount = {
        name = module.this.name
      }
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    })
  ])

  context = module.this.context
}
