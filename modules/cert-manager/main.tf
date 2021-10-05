locals {
  enabled = module.this.enabled
  # Role ARN of IAM Role created by the helm-release module
  # e.g. arn:aws:iam::123456789012:role/acme-mgmt-uw2-dev-external-dns-external-dns@kube-system
  # needs to be calculated manually in order to avoid a cyclic dependency.
  iam_role_arn = "arn:${join("", data.aws_partition.current.*.partition)}:iam::${join("", data.aws_caller_identity.current.*.account_id)}:role/${module.this.id}-${module.this.name}@${var.kubernetes_namespace}"
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

module "cert_manager" {
  source  = "cloudposse/helm-release/aws"
  version = "0.1.4"

  name                 = module.this.name
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

  # Only install IAM role if letsencrypt_installed is enabled
  iam_role_enabled = var.letsencrypt_enabled

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

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
          [for value in module.dns_delegated.outputs.zones : value.zone_id],
          [for value in module.dns_gbl_delegated.outputs.zones : value.zone_id]
        ) :
        "arn:${join("", data.aws_partition.current.*.partition)}:route53:::hostedzone/${zone_id}"
      ]
      conditions : []
    }
  ]

  values = compact([
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      resources = var.cert_manager_resources
    }),
    var.letsencrypt_enabled ? yamlencode({
      ingressShim = {
        defaultIssuerName                = "ClusterIssuer"
        ingress_shim_default_issuer_name = "letsencrypt-staging"
      },
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = local.iam_role_arn
        }
      }
    }) : "",
    var.cert_manager_metrics_enabled ? yamlencode({
      prometheus = {
        enabled = var.cert_manager_metrics_enabled
        servicemonitor = {
          enabled = var.cert_manager_metrics_enabled
        }
      }
    }) : "",
    file("${path.module}/cert-manager-values.yaml"),
  ])

  context = module.this.context
}

module "cert_manager_issuer" {
  source  = "cloudposse/helm-release/aws"
  version = "0.1.3"

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
  values = [
    yamlencode({
      letsencrypt_installed  = var.letsencrypt_enabled
      selfsigned_installed   = var.cert_manager_issuer_selfsigned_enabled
      account                = join("-", compact([module.this.tenant, module.this.stage]))
      support_email_template = var.cert_manager_issuer_support_email_template
    })
  ]

  context = module.this.context

  depends_on = [
    module.cert_manager # CRDs from cert-manager need to be installed first
  ]
}
