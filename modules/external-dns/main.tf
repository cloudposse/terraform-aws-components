locals {
  enabled = module.this.enabled
  # Chart `sources` to watch 
  source_defaults = ["service", "ingress"]
  source_istio    = var.istio_enabled ? ["istio-gateway"] : []
  source_crd      = var.crd_enabled ? ["crd"] : []
  sources         = concat(local.source_defaults, local.source_istio, local.source_crd)
  txt_owner       = var.txt_prefix != "" ? format(module.this.tenant != null ? "%[1]s-%[2]s-%[3]s-%[4]s" : "%[1]s-%[2]s-%[4]s", var.txt_prefix, module.this.environment, module.this.tenant, module.this.stage) : ""
  txt_prefix      = var.txt_prefix != "" ? format("%s-", local.txt_owner) : ""
  zone_ids = compact(concat(
    values(module.dns_delegated.outputs.zones)[*].zone_id,
    values(module.dns_gbl_delegated.outputs.zones)[*].zone_id
  ))
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

module "external_dns" {
  source  = "cloudposse/helm-release/aws"
  version = "0.1.4"

  name                 = module.this.name
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

  iam_role_enabled = true
  iam_policy_statements = [
    {
      sid = "GrantChangeResourceRecordSets"

      actions = [
        "route53:ChangeResourceRecordSets"
      ]

      effect    = "Allow"
      resources = formatlist("arn:aws:route53:::hostedzone/%s", local.zone_ids)
    },
    {
      sid = "GrantListHostedZonesListResourceRecordSets"

      actions = [
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:ListResourceRecordSets"
      ]

      effect    = "Allow"
      resources = ["*"]
    },
  ]

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = var.name,
      serviceAccount = {
        name = module.this.name
        annotations = {
          "eks.amazonaws.com/role-arn" = local.iam_role_arn
        }
      },
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # standard metrics settings
    var.metrics_enabled ? yamlencode({
      prometheus = {
        enabled = var.metrics_enabled
        servicemonitor = {
          enabled = var.metrics_enabled
        }
      }
    }) : "",
    # external-dns-specific values
    yamlencode({
      aws = {
        region = var.region
      }
      policy                  = var.policy
      publishInternalServices = var.publish_internal_services
      txtOwnerId              = local.txt_owner
      txtPrefix               = local.txt_prefix
      source                  = local.sources
    }),
    # hardcoded values
    file("${path.module}/resources/values.yaml"),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
