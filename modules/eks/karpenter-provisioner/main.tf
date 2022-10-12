# Create Provisioning Configuration
# https://karpenter.sh/v0.10.1/aws/provisioning
# https://karpenter.sh/v0.10.1
# https://karpenter.sh/v0.10.1/provisioner/#specrequirements
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1545

locals {
  enabled = module.this.enabled

  private_subnet_ids = module.vpc.outputs.private_subnet_ids
  public_subnet_ids  = module.vpc.outputs.public_subnet_ids

  provisioners = { for k, v in var.provisioners : k => v if local.enabled }
}

resource "kubernetes_manifest" "default" {
  for_each = local.provisioners

  manifest = {
    "apiVersion" = "karpenter.sh/v1alpha5"
    "kind"       = "Provisioner"
    "metadata" = {
      "name" = each.value.name
    }
    "spec" = {
      "limits" = {
        "resources" = {
          "cpu"    = each.value.total_cpu_limit
          "memory" = each.value.total_memory_limit
        }
      }
      "provider" = {
        "subnetSelector" = {
          # https://karpenter.sh/v0.10.1/aws/provisioning/#subnetselector-required
          "aws-ids" : join(",", each.value.private_subnets_enabled ? local.private_subnet_ids : local.public_subnet_ids)
        }
        "securityGroupSelector" = {
          "aws:eks:cluster-name" = local.eks_cluster_id
        }
        # https://karpenter.sh/v0.10.1/aws/provisioning/#amazon-machine-image-ami-family
        "amiFamily" = each.value.ami_family
      }
      "ttlSecondsAfterEmpty"   = each.value.ttl_seconds_after_empty
      "ttlSecondsUntilExpired" = each.value.ttl_seconds_until_expired
      "requirements"           = each.value.requirements
      # https://aws.github.io/aws-eks-best-practices/karpenter/#create-provisioners-that-are-mutually-exclusive
      "taints"        = each.value.taints
      "startupTaints" = each.value.startup_taints
    }
  }
}
