output "metadata" {
  value       = module.gha_runner_controller.metadata
  description = "Block status of the deployed release"
}

output "runners" {
  value = { for k, v in local.enabled_runners : k => merge({
    "1) Kubernetes namespace" = coalesce(v.kubernetes_namespace, local.controller_namespace)
    "2) Runner Group"         = v.group
    "3) Min Runners"          = v.min_replicas
    "4) Max Runners"          = v.max_replicas
    },
    length(v.node_selector) > 0 ? {
      "?) Node Selector" = v.node_selector
    } : {},
    length(v.tolerations) > 0 ? {
      "?) Tolerations" = v.tolerations
    } : {},
    length(v.affinity) > 0 ? {
      "?) Affinity" = v.affinity
    } : {},
    )
  }
  description = "Human-readable summary of the deployed runners"
}
