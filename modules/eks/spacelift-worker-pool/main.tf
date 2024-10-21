# https://docs.spacelift.io/concepts/worker-pools#kubernetes
# https://docs.spacelift.io/integrations/docker#customizing-the-runner-image

locals {
  enabled = module.this.enabled

  eks_outputs                      = module.eks.outputs
  eks_cluster_identity_oidc_issuer = try(local.eks_outputs.eks_cluster_identity_oidc_issuer, "")

  existing_spaces = { for i in data.spacelift_spaces.default[0].spaces : i.name => i if local.enabled }
  space_id        = local.enabled ? local.existing_spaces[var.space_name].space_id : ""
}

# Read all the existing spaces from Spacelift
data "spacelift_spaces" "default" {
  count = local.enabled ? 1 : 0
}

# Create worker pool in Spacelift
# https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/worker_pool
resource "spacelift_worker_pool" "default" {
  count = local.enabled ? 1 : 0

  name     = module.this.id
  space_id = local.space_id

  description = var.worker_pool_description != null && var.worker_pool_description != "" ? var.worker_pool_description : (
    "Worker Pool on Kubernetes deployed into ${local.eks_cluster_id} EKS cluster in Spacelift ${local.space_id} space"
  )
}
