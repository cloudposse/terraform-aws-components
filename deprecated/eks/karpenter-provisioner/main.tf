# Create Provisioning Configuration
# https://karpenter.sh/v0.18.0/aws/provisioning
# https://karpenter.sh/v0.18.0
# https://karpenter.sh/v0.18.0/provisioner/#specrequirements
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1545

locals {
  enabled = module.this.enabled

  private_subnet_ids = module.vpc.outputs.private_subnet_ids
  public_subnet_ids  = module.vpc.outputs.public_subnet_ids

  provisioners = { for k, v in var.provisioners : k => v if local.enabled }
}

resource "kubernetes_manifest" "provisioner" {
  for_each = local.provisioners

  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = each.value.name
    }
    spec = merge(
      {
        limits = {
          resources = {
            cpu    = each.value.total_cpu_limit
            memory = each.value.total_memory_limit
          }
        }
        providerRef = {
          name = each.value.name
        }
        requirements  = each.value.requirements
        consolidation = each.value.consolidation
        # Do not include keys with null values, or else Terraform will show a perpetual diff.
        # Use `try(length(),0)` to detect both empty lists and nulls.
      },
      try(length(each.value.taints), 0) == 0 ? {} : {
        taints = each.value.taints
      },
      try(length(each.value.startup_taints), 0) == 0 ? {} : {
        startupTaints = each.value.startup_taints
      },
      each.value.ttl_seconds_after_empty == null ? {} : {
        ttlSecondsAfterEmpty = each.value.ttl_seconds_after_empty
      },
      each.value.ttl_seconds_until_expired == null ? {} : {
        ttlSecondsUntilExpired = each.value.ttl_seconds_until_expired
      },
    )
  }

  # spec.requirements counts as a computed field because defaults may be added by the admission webhook.
  computed_fields = ["spec.requirements"]

  depends_on = [kubernetes_manifest.provider]

  lifecycle {
    precondition {
      condition     = each.value.consolidation.enabled == false || each.value.ttl_seconds_after_empty == null
      error_message = "Consolidation and TTL Seconds After Empty are mutually exclusive."
    }
  }
}

locals {
  # If you include a field but set it to null, the field will be omitted from the Kubernetes resource,
  # but the Kubernetes provider will still try to include it with a null value,
  # which will cause perpetual diff in the Terraform plan.
  # We strip out the null values from block_device_mappings here, because it is complicated.
  provisioner_block_device_mappings = { for pk, pv in local.provisioners : pk => [
    for i, map in pv.block_device_mappings : merge({
      for dk, dv in map : dk => dv if dk != "ebs" && dv != null
    }, try(length(map.ebs), 0) == 0 ? {} : { ebs = { for ek, ev in map.ebs : ek => ev if ev != null } })
    ]
  }
}

resource "kubernetes_manifest" "provider" {
  for_each = local.provisioners

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1alpha1"
    kind       = "AWSNodeTemplate"
    metadata = {
      name = each.value.name
    }
    spec = merge({
      subnetSelector = {
        # https://karpenter.sh/v0.18.0/aws/provisioning/#subnetselector-required
        aws-ids = join(",", each.value.private_subnets_enabled ? local.private_subnet_ids : local.public_subnet_ids)
      }
      securityGroupSelector = {
        "aws:eks:cluster-name" = local.eks_cluster_id
      }
      # https://karpenter.sh/v0.18.0/aws/provisioning/#amazon-machine-image-ami-family
      amiFamily       = each.value.ami_family
      metadataOptions = each.value.metadata_options
      tags            = module.this.tags
      }, try(length(local.provisioner_block_device_mappings[each.key]), 0) == 0 ? {} : {
      blockDeviceMappings = local.provisioner_block_device_mappings[each.key]
    })
  }
}
