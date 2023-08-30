locals {
  fargate_profiles                        = local.enabled ? var.fargate_profiles : {}
  fargate_cluster_pod_execution_role_name = "${local.eks_cluster_id}-fargate"
  fargate_cluster_pod_execution_role_needed = local.enabled && (
    local.addons_require_fargate ||
    ((length(var.fargate_profiles) > 0) && !var.legacy_fargate_1_role_per_profile_enabled)
  )
}

module "fargate_pod_execution_role" {
  count = local.fargate_cluster_pod_execution_role_needed ? 1 : 0

  source  = "cloudposse/eks-fargate-profile/aws"
  version = "1.3.0"

  subnet_ids           = local.private_subnet_ids
  cluster_name         = local.eks_cluster_id
  permissions_boundary = var.fargate_profile_iam_role_permissions_boundary

  fargate_profile_enabled            = false
  fargate_pod_execution_role_enabled = true
  fargate_pod_execution_role_name    = local.fargate_cluster_pod_execution_role_name

  context = module.this.context
}


###############################################################################
### Both New and Legacy behavior, use caution when modifying
###############################################################################
module "fargate_profile" {
  source  = "cloudposse/eks-fargate-profile/aws"
  version = "1.3.0"

  for_each = local.fargate_profiles

  subnet_ids                              = local.private_subnet_ids
  cluster_name                            = local.eks_cluster_id
  kubernetes_namespace                    = each.value.kubernetes_namespace
  kubernetes_labels                       = each.value.kubernetes_labels
  permissions_boundary                    = var.fargate_profile_iam_role_permissions_boundary
  iam_role_kubernetes_namespace_delimiter = var.fargate_profile_iam_role_kubernetes_namespace_delimiter

  ## Legacy switch
  fargate_pod_execution_role_enabled = var.legacy_fargate_1_role_per_profile_enabled
  fargate_pod_execution_role_arn     = var.legacy_fargate_1_role_per_profile_enabled ? null : one(module.fargate_pod_execution_role[*].eks_fargate_pod_execution_role_arn)

  context = module.this.context
}
