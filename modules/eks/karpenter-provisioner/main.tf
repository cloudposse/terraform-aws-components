# Karpenter Node Pool and Class Configuration
# https://karpenter.sh/v0.34/getting-started/getting-started-with-karpenter/

locals {
  enabled = module.this.enabled

  private_subnet_ids = module.vpc.outputs.private_subnet_ids
  public_subnet_ids  = module.vpc.outputs.public_subnet_ids

  node_pools   = { for k, v in var.node_pools : k => v if local.enabled }
  node_classes = { for k, v in var.node_classes : k => v if local.enabled }
}

# Documentation: https://karpenter.sh/v0.34/concepts/nodepools/
resource "kubernetes_manifest" "node_pool" {
  for_each = local.node_pools

  # spec.requirements counts as a computed field because defaults may be added by the admission webhook.
  computed_fields = ["spec.template.spec.requirements"]

  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = each.key
    }
    spec = {
      template = {
        spec = merge(
          {
            nodeClassRef = { name = each.value.node_class }
            requirements = each.value.requirements
          },
          try(length(each.value.taints), 0) == 0 ? {} : {
            taints = each.value.taints
          },
          try(length(each.value.startup_taints), 0) == 0 ? {} : {
            startupTaints = each.value.startup_taints
          },
        )
      }
      disruption = try(length(each.value.disruption), 0) == 0 ? null : {
        // exclude keys with null values or empty lists
        for k, v in {
          consolidationPolicy = each.value.disruption.consolidation_policy
          consolidateAfter    = each.value.disruption.consolidate_after
          expireAfter         = each.value.disruption.expire_after
          budgets             = each.value.disruption.budgets
        } : k => v if try(length(v), 0) > 0
      }
      limits = {
        cpu    = each.value.total_cpu_limit
        memory = each.value.total_memory_limit
      }
    }
  }

  depends_on = [kubernetes_manifest.node_class]
}

# Documentation: https://karpenter.sh/v0.34/concepts/nodeclasses/
resource "kubernetes_manifest" "node_class" {
  for_each = local.node_classes

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "EC2NodeClass"
    metadata = {
      name = each.key
    }
    spec = merge(
      {
        amiFamily = each.value.ami_family
        role      = module.eks.outputs.karpenter_iam_role_name
        subnetSelectorTerms = [
          for x in(each.value.private_subnets_enabled ? local.private_subnet_ids : local.public_subnet_ids) : {
            id = x
          }
        ]
        securityGroupSelectorTerms = [{
          tags = {
            "aws:eks:cluster-name" = local.eks_cluster_id
          }
        }]
        blockDeviceMappings = [
          for bdm in each.value.block_device_mappings : {
            deviceName = bdm.device_name
            ebs = {
              // exclude keys with null values
              for k, v in {
                volumeSize          = bdm.ebs.volume_size
                volumeType          = bdm.ebs.volume_type
                deleteOnTermination = bdm.ebs.delete_on_termination
                encrypted           = bdm.ebs.encrypted
                iops                = bdm.ebs.iops
                kmsKeyId            = bdm.ebs.kms_key_id
                snapshotId          = bdm.ebs.snapshot_id
                throughput          = bdm.ebs.throughput
              } : k => v if v != null
            }
          }
        ]
        tags = module.this.tags
      },
      try(length(each.value.metadata_options), 0) == 0 ? {} : {
        metadataOptions = {
          // exclude keys with null values
          for k, v in {
            httpEndpoint            = each.value.metadata_options.http_endpoint
            httpProtocalIPv6        = each.value.metadata_options.http_protocal_ipv6
            httpPutResponseHopLimit = each.value.metadata_options.http_put_response_hop_limit
            httpTokens              = each.value.metadata_options.http_tokens
          } : k => v if v != null
        }
      }
    )
  }
}
