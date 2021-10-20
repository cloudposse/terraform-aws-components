locals {
  enabled = module.this.enabled
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "cert_manager" {
  source  = "cloudposse/helm-release/aws"
  version = "0.2.1"

  name                 = "" # avoids hitting length restrictions on IAM Role names
  chart                = var.cert_manager_chart
  repository           = var.cert_manager_repository
  description          = var.cert_manager_description
  chart_version        = var.cert_manager_chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  # Only install IAM role if letsencrypt_enabled is true
  iam_role_enabled = var.letsencrypt_enabled

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name                        = module.this.name
  service_account_namespace                   = var.kubernetes_namespace
  service_account_role_arn_annotation_enabled = var.letsencrypt_enabled

  iam_policy_statements = [
    {
      sid    = "GrantGetChange"
      effect = "Allow"
      actions = [
        "route53:GetChange"
      ]
      resources = [
        "arn:${join("", data.aws_partition.current.*.partition)}:route53:::change/*"
      ]
      conditions = []
    },
    {
      sid    = "GrantListHostedZonesListResourceRecordSets"
      effect = "Allow"
      actions = [
        "route53:ListHostedZonesByName"
      ]
      resources  = ["*"]
      conditions = []
    },
    {
      sid    = "GrantChangeResourceRecordSets"
      effect = "Allow"
      actions = [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
      ]
      resources = [
        for zone_id in concat(
          # [for value in module.dns_delegated.outputs.zones : value.zone_id],
          [],
          [for value in module.dns_gbl_delegated.outputs.zones : value.zone_id]
        ) :
        "arn:${join("", data.aws_partition.current.*.partition)}:route53:::hostedzone/${zone_id}"
      ]
      conditions : []
    }
  ]

  values = compact([
    # hardcoded values
    file("${path.module}/resources/cert-manager-values.yaml"),
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      resources = var.cert_manager_resources
      rbac = {
        create = var.cart_manager_rbac_enabled
      }
    }),
    # cert-manager-specific values
    var.letsencrypt_enabled ? yamlencode({
      ingressShim = {
        defaultIssuerName                = "ClusterIssuer"
        ingress_shim_default_issuer_name = "letsencrypt-staging"
      },
    }) : "",
    var.cert_manager_metrics_enabled ? yamlencode({
      prometheus = {
        enabled = var.cert_manager_metrics_enabled
        servicemonitor = {
          enabled = var.cert_manager_metrics_enabled
        }
      }
    }) : "",
    # additional values
    yamlencode(var.cert_manager_values)
  ])

  context = module.this.context
}

module "cert_manager_issuer" {
  source  = "cloudposse/helm-release/aws"
  version = "0.2.1"

  # Only install the issuer if either letsencrypt_installed or selfsigned_installed is true
  enabled = local.enabled && (var.letsencrypt_enabled || var.cert_manager_issuer_selfsigned_enabled)

  name                 = "${module.this.name}-issuer"
  chart                = var.cert_manager_issuer_chart
  repository           = var.cert_manager_issuer_repository
  description          = var.cert_manager_issuer_description
  chart_version        = var.cert_manager_issuer_chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  # NOTE: Use with the local chart
  values = compact([
    yamlencode({
      letsencrypt_installed  = var.letsencrypt_enabled
      selfsigned_installed   = var.cert_manager_issuer_selfsigned_enabled
      account                = join("-", compact([module.this.tenant, module.this.stage]))
      support_email_template = var.cert_manager_issuer_support_email_template
      stage                  = var.stage
      dns_region             = var.region
    }),
    yamlencode(var.cert_manager_issuer_values)
  ])

  context = module.this.context

  depends_on = [
    module.cert_manager # CRDs from cert-manager need to be installed first
  ]
}
