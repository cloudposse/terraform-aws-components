locals {
  enabled = module.this.enabled

  # https://docs.datadoghq.com/synthetics/private_locations/configuration
  # docker run --rm datadog/synthetics-private-location-worker --help
  private_location_config = jsondecode(join("", datadog_synthetics_private_location.this.*.config))
}

resource "datadog_synthetics_private_location" "this" {
  count       = local.enabled ? 1 : 0
  name        = module.this.id
  description = module.this.id
  tags        = var.private_location_tags
}


module "datadog_synthetics_private_location" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name          = module.this.name
  chart         = var.chart
  description   = var.description
  repository    = var.repository
  chart_version = var.chart_version

  kubernetes_namespace = var.kubernetes_namespace

  # Usually set to `false` if deploying eks/datadog-agent, since namespace will already be created
  create_namespace_with_kubernetes = var.create_namespace

  verify          = var.verify
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled = false

  values = [
    templatefile(
      "${path.module}/values.yaml.tpl",
      {
        id                    = local.private_location_config.id,
        datadogApiKey         = module.datadog_configuration.datadog_api_key,
        accessKey             = local.private_location_config.accessKey,
        secretAccessKey       = local.private_location_config.secretAccessKey,
        privateKey            = replace(local.private_location_config.privateKey, "\n", "\n      "),
        publicKey_pem         = replace(local.private_location_config.publicKey.pem, "\n", "\n      "),
        publicKey_fingerprint = local.private_location_config.publicKey.fingerprint,
        site                  = local.private_location_config.site
      }
    )
  ]

  context = module.this.context
}
