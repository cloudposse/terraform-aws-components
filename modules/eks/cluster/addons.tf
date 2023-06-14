# https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html

locals {
  eks_cluster_oidc_issuer_url = replace(local.eks_outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  addon_names                = keys(var.addons)
  vpc_cni_addon_enabled      = local.enabled && contains(local.addon_names, "vpc-cni")
  aws_ebs_csi_driver_enabled = local.enabled && contains(local.addon_names, "aws-ebs-csi-driver")

  # The `vpc-cni` and `aws-ebs-csi-driver` addons are special as they always require an IAM role for Kubernetes Service Account (IRSA).
  # The roles are created by this component.
  addon_service_account_role_arn_map = {
    vpc-cni            = module.vpc_cni_eks_iam_role.service_account_role_arn
    aws-ebs-csi-driver = module.aws_ebs_csi_driver_eks_iam_role.service_account_role_arn
  }

  addons = [
    for k, v in var.addons : {
      addon_name               = k
      addon_version            = lookup(v, "addon_version", null)
      resolve_conflicts        = lookup(v, "resolve_conflicts", null)
      service_account_role_arn = try(coalesce(lookup(v, "service_account_role_arn", null), lookup(local.addon_service_account_role_arn_map, k, null)), null)
    }
  ]
}

# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-role
# https://aws.github.io/aws-eks-best-practices/networking/vpc-cni/#deploy-vpc-cni-managed-add-on
data "aws_iam_policy" "vpc_cni" {
  count = local.vpc_cni_addon_enabled ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

module "vpc_cni_eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.0"

  enabled = local.vpc_cni_addon_enabled

  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

  service_account_name      = "aws-node"
  service_account_namespace = "kube-system"

  aws_iam_policy_document = [one(data.aws_iam_policy.vpc_cni[*].policy)]

  context = module.this.context
}

# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons
# https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#csi-iam-role
# https://github.com/kubernetes-sigs/aws-ebs-csi-driver
data "aws_iam_policy" "aws_ebs_csi_driver" {
  count = local.aws_ebs_csi_driver_enabled ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "aws_ebs_csi_driver_eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.0"

  enabled = local.aws_ebs_csi_driver_enabled

  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

  service_account_name      = "ebs-csi-controller-sa"
  service_account_namespace = "kube-system"

  aws_iam_policy_document = [one(data.aws_iam_policy.aws_ebs_csi_driver[*].policy)]

  context = module.this.context
}
