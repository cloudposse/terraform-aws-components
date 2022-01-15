# <-- BEGIN DOC -->
#
# This mixin is meant to be added to Terraform EKS components which are used in a cluster where sops-secrets-operator (see: https://github.com/isindir/sops-secrets-operator)
# is deployed. It will then allow for SOPS-encrypted SopsSecret CRD manifests (such as `example.sops.yaml`) placed in a
# `resources/` directory to be deployed to the cluster alongside the EKS component.
#
# This mixin assumes that the EKS component in question follows the same pattern as `alb-controller`, `cert-manager`, `external-dns`,
# etc. That is, that it has the following characteristics:
#
# 1. Has a `var.kubernetes_namespace` variable.
# 2. Does not already instantiate a Kubernetes provider (only the Helm provider is necessary, typically, for EKS components).
#
# <-- END DOC -->

locals {
  sops_kubernetes_host                   = module.this.enabled ? data.aws_eks_cluster.kubernetes[0].endpoint : ""
  sops_kubernetes_token                  = module.this.enabled ? data.aws_eks_cluster_auth.kubernetes[0].token : ""
  sops_kubernetes_cluster_ca_certificate = module.this.enabled ? base64decode(data.aws_eks_cluster.kubernetes[0].certificate_authority[0].data) : ""
  sops_secrets = module.this.enabled ? {
    for file in var.sops_secrets : file => yamldecode(file(format("%s/%s", var.sops_secrets_directory, file)))
  } : {}
}

provider "kubernetes" {
  host                   = local.kubernetes_host
  token                  = local.kubernetes_token
  cluster_ca_certificate = local.kubernetes_cluster_ca_certificate
}

resource "kubernetes_manifest" "sops_secret" {
  for_each = local.sops_secrets

  manifest = {
    apiVersion = each.value.apiVersion
    kind       = each.value.kind
    metadata = {
      name      = each.value.metadata.name
      namespace = var.kubernetes_namespace
    }
    spec = each.value.spec
    sops = each.value.sops
  }

  field_manager {
    force_conflicts = true
  }
}

variable "sops_secrets_directory" {
  type        = string
  description = <<-EOT
  The directory (relative to the component) where the SOPS-encrypted SopsSecret CRD manifests exist.

  This directory should *not* contain a trailing forward slash.
  EOT
  default     = "./resources"
}

variable "sops_secrets" {
  type        = list(string)
  description = <<-EOT
  List of SOPS-encrypted SopsSecret file names, as they appear within the directory specified by `sops_secrets_directory`.
  EOT
  default     = []
}

output "sops_secrets" {
  value = {
    for sops_secret in kubernetes_manifest.sops_secret : sops_secret.manifest.metadata.name =>
    {
      templated_secrets = [for secret_template in sops_secret.manifest.spec.secretTemplates : secret_template.name]
    }
  }
}
