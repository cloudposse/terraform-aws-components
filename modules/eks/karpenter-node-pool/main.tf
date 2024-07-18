# Create Provisioning Configuration
# https://karpenter.sh/docs/concepts/

locals {
  enabled = module.this.enabled

  private_subnet_ids = module.vpc.outputs.private_subnet_ids
  public_subnet_ids  = module.vpc.outputs.public_subnet_ids

  node_pools = { for k, v in var.node_pools : k => v if local.enabled }
  kubelets_specs_filtered = { for k, v in local.node_pools : k => {
    for kk, vv in v.kubelet : kk => vv if vv != null
    }
  }
  kubelet_specs = { for k, v in local.kubelets_specs_filtered : k => v if length(v) > 0 }
}

# https://karpenter.sh/docs/concepts/nodepools/

resource "kubernetes_manifest" "node_pool" {
  for_each = local.node_pools

  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = coalesce(each.value.name, each.key)
    }
    spec = {
      limits = {
        cpu    = each.value.total_cpu_limit
        memory = each.value.total_memory_limit
      }
      weight = each.value.weight
      disruption = merge({
        consolidationPolicy = each.value.disruption.consolidation_policy
        expireAfter         = each.value.disruption.max_instance_lifetime
        },
        each.value.disruption.consolidate_after == null ? {} : {
          consolidateAfter = each.value.disruption.consolidate_after
        },
        length(each.value.disruption.budgets) == 0 ? {} : {
          budgets = each.value.disruption.budgets
        }
      )
      template = {
        metadata = {
          labels      = coalesce(each.value.labels, {})
          annotations = coalesce(each.value.annotations, {})
        }
        spec = merge({
          nodeClassRef = {
            apiVersion = "karpenter.k8s.aws/v1beta1"
            kind       = "EC2NodeClass"
            name       = coalesce(each.value.name, each.key)
          }
          },
          try(length(each.value.requirements), 0) == 0 ? {} : {
            requirements = [for r in each.value.requirements : merge({
              key      = r.key
              operator = r.operator
              },
              try(length(r.values), 0) == 0 ? {} : {
                values = r.values
            })]
          },
          try(length(each.value.taints), 0) == 0 ? {} : {
            taints = each.value.taints
          },
          try(length(each.value.startup_taints), 0) == 0 ? {} : {
            startupTaints = each.value.startup_taints
          },
          try(local.kubelet_specs[each.key], null) == null ? {} : {
            kubelet = local.kubelet_specs[each.key]
          }
        )
      }
    }
  }

  depends_on = [kubernetes_manifest.ec2_node_class]
}
