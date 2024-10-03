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
    values(module.dns_gbl_delegated.outputs.zones)[*].zone_id,
    values(module.dns_gbl_primary.outputs.zones)[*].zone_id,
    flatten([for k, v in module.additional_dns_components : [for i, j in v.outputs.zones : j.zone_id]])
  ))
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "external_dns" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  name            = module.this.name
  chart           = var.chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = var.create_namespace
  kubernetes_namespace             = var.kubernetes_namespace
  kubernetes_namespace_labels      = merge(module.this.tags, { name = var.kubernetes_namespace })


  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

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
      resources = formatlist("arn:${join("", data.aws_partition.current.*.partition)}:route53:::hostedzone/%s", local.zone_ids)
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
      sources                 = local.sources
    }),
    # hardcoded values
    file("${path.module}/resources/values.yaml"),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
