locals {
  enabled      = module.this.enabled
  account_name = lookup(module.this.descriptors, "account_name", module.this.stage)
  account      = module.account_map.outputs.full_account_map[local.account_name]
}

resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = module.this.tags
  }
}

# CRDs are automatically installed by "cloudposse/helm-release/aws"
# https://external-secrets.io/v0.5.9/guides-getting-started/
module "external_secrets_operator" {
  source  = "cloudposse/helm-release/aws"
  version = "0.5.0"

  name        = "" # avoids hitting length restrictions on IAM Role names
  description = "External Secrets Operator is a Kubernetes operator that integrates external secret management systems including AWS SSM, Parameter Store, Hasicorp Vault, 1Password Secrets Automation, etc. It reads values from external vaults and injects values as a Kubernetes Secret"

  repository           = "https://charts.external-secrets.io"
  chart                = "external-secrets"
  chart_version        = "0.6.0-rc1" # using RC to address this bug https://github.com/external-secrets/external-secrets/issues/1511
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  create_namespace     = false
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled = true
  iam_policy_statements = {
    ReadParameterStore = {
      effect = "Allow"
      actions = [
        "ssm:GetParameter*"
      ]
      resources = [for parameter_store_path in var.parameter_store_paths : (
        "arn:aws:ssm:${var.region}:${local.account}:parameter/${parameter_store_path}/*"
      )]
    }
    DescribeParameters = {
      effect = "Allow"
      actions = [
        "ssm:DescribeParameter*"
      ]
      resources = [
        "arn:aws:ssm:${var.region}:${local.account}:*"
      ]
    }
  }

  values = compact([
    yamlencode({
      serviceAccount = {
        name = module.this.name
      }
      rbac = {
        create = var.rbac_enabled
      }
    })
  ])

  context = module.this.context
}

module "external_ssm_secrets" {
  source  = "cloudposse/helm-release/aws"
  version = "0.5.0"

  name        = "ssm" # avoids hitting length restrictions on IAM Role names
  description = "This Chart uses creates a SecretStore and ExternalSecret to pull variables (under a given path) from AWS SSM Parameter Store into a Kubernetes secret."

  chart                = "${path.module}/charts/external-ssm-secrets"
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  create_namespace     = false
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  service_account_name                        = module.this.name
  service_account_namespace                   = var.kubernetes_namespace
  service_account_role_arn_annotation_enabled = true
  service_account_set_key_path                = "role"

  values = compact([
    yamlencode({
      region                = var.region,
      parameter_store_paths = var.parameter_store_paths
      resources             = var.resources
      serviceAccount = {
        name = module.this.name
      }
      rbac = {
        create = var.rbac_enabled
      }
    })
  ])

  context = module.this.context

  depends_on = [
    # CRDs from external_secrets_operator need to be installed first
    module.external_secrets_operator,
  ]
}

