locals {
  fargate_profiles = local.enabled ? var.fargate_profiles : {}
}

module "fargate_profile" {
  source  = "cloudposse/eks-fargate-profile/aws"
  version = "1.1.0"

  for_each = local.fargate_profiles

  subnet_ids                              = local.private_subnet_ids
  cluster_name                            = module.eks_cluster.eks_cluster_id
  kubernetes_namespace                    = each.value.kubernetes_namespace
  kubernetes_labels                       = each.value.kubernetes_labels
  permissions_boundary                    = var.fargate_profile_iam_role_permissions_boundary
  iam_role_kubernetes_namespace_delimiter = var.fargate_profile_iam_role_kubernetes_namespace_delimiter

  context = module.this.context
}
