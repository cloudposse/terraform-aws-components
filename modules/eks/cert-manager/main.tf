locals {
  enabled   = module.this.enabled
  partition = join("", data.aws_partition.current[*].partition)
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "cert_manager" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  name            = "" # avoids hitting length restrictions on IAM Role names
  chart           = var.cert_manager_chart
  repository      = var.cert_manager_repository
  description     = var.cert_manager_description
  chart_version   = var.cert_manager_chart_version
  wait            = var.wait || var.letsencrypt_enabled || var.cert_manager_issuer_selfsigned_enabled
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = var.create_namespace
  kubernetes_namespace             = var.kubernetes_namespace
  kubernetes_namespace_labels      = merge(module.this.tags, { name = var.kubernetes_namespace })

  # Only install IAM role if letsencrypt_enabled is true
  iam_role_enabled            = var.letsencrypt_enabled
  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  service_account_name                        = module.this.name
  service_account_namespace                   = var.kubernetes_namespace
  service_account_role_arn_annotation_enabled = var.letsencrypt_enabled

  iam_policy_statements = {
    GrantGetChange = {
      effect = "Allow"
      actions = [
        "route53:GetChange"
      ]
      resources = [
        "arn:${local.partition}:route53:::change/*"
      ]
      conditions = []
    }
    GrantListHostedZonesListResourceRecordSets = {
      effect = "Allow"
      actions = [
        "route53:ListHostedZonesByName"
      ]
      resources  = ["*"]
      conditions = []
    },
    GrantChangeResourceRecordSets = {
      effect = "Allow"
      actions = [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
      ]
      resources = [
        for zone_id in concat(
          [],
          [for value in module.dns_gbl_delegated.outputs.zones : value.zone_id]
        ) :
        "arn:${local.partition}:route53:::hostedzone/${zone_id}"
      ]
      conditions : []
    }
  }

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
  version = "0.10.0"

  # Only install the issuer if either letsencrypt_installed or selfsigned_installed is true
  enabled = local.enabled && (var.letsencrypt_enabled || var.cert_manager_issuer_selfsigned_enabled)

  name                 = "${module.this.name}-issuer"
  chart                = var.cert_manager_issuer_chart
  repository           = var.cert_manager_issuer_repository
  description          = var.cert_manager_issuer_description
  chart_version        = var.cert_manager_issuer_chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = false
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  # IAM role will be created by the cert-manager module above, if needed. Do not create a duplicate here.
  iam_role_enabled            = false
  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

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
    # CRDs from cert-manager need to be installed first
    module.cert_manager,
  ]
}
