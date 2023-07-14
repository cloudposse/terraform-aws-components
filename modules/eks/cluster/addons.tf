# https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
# https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on

locals {
  eks_cluster_oidc_issuer_url = replace(local.eks_outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  addon_names                = keys(var.addons)
  vpc_cni_addon_enabled      = local.enabled && contains(local.addon_names, "vpc-cni")
  aws_ebs_csi_driver_enabled = local.enabled && contains(local.addon_names, "aws-ebs-csi-driver")
  coredns_enabled            = local.enabled && contains(local.addon_names, "coredns")

  # The `vpc-cni` and `aws-ebs-csi-driver` addons are special as they always require an IAM role for Kubernetes Service Account (IRSA).
  # The roles are created by this component.
  addon_service_account_role_arn_map = {
    vpc-cni            = module.vpc_cni_eks_iam_role.service_account_role_arn
    aws-ebs-csi-driver = module.aws_ebs_csi_driver_eks_iam_role.service_account_role_arn
  }

  final_addon_service_account_role_arn_map = merge(local.addon_service_account_role_arn_map, local.overridable_additional_addon_service_account_role_arn_map)

  addons = [
    for k, v in var.addons : {
      addon_name               = k
      addon_version            = lookup(v, "addon_version", null)
      configuration_values     = lookup(v, "configuration_values", null)
      resolve_conflicts        = lookup(v, "resolve_conflicts", null)
      service_account_role_arn = try(coalesce(lookup(v, "service_account_role_arn", null), lookup(local.final_addon_service_account_role_arn_map, k, null)), null)
    }
  ]

  addons_depends_on = concat([
    module.aws_ebs_csi_driver_fargate_profile,
    module.coredns_fargate_profile,
  ], local.overridable_addons_depends_on)

  addons_require_fargate = var.deploy_addons_to_fargate && (
    local.aws_ebs_csi_driver_enabled ||
    local.coredns_enabled ||
    local.overridable_deploy_additional_addons_to_fargate
  )
  addon_fargate_profiles = merge(
    (local.aws_ebs_csi_driver_enabled && var.deploy_addons_to_fargate ? {
      aws_ebs_csi_driver = one(module.aws_ebs_csi_driver_fargate_profile[*])
    } : {}),
    (local.coredns_enabled && var.deploy_addons_to_fargate ? {
      coredns = one(module.coredns_fargate_profile[*])
    } : {}),
    local.overridable_additional_addon_fargate_profiles
  )
}

# `vpc-cni` EKS addon
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-role
# https://aws.github.io/aws-eks-best-practices/networking/vpc-cni/#deploy-vpc-cni-managed-add-on
data "aws_iam_policy_document" "vpc_cni_ipv6" {
  count = local.vpc_cni_addon_enabled ? 1 : 0

  # See https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:ec2:*:*:network-interface/*"]
    actions   = ["ec2:CreateTags"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count = local.vpc_cni_addon_enabled ? 1 : 0

  role       = module.vpc_cni_eks_iam_role.service_account_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

module "vpc_cni_eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.0"

  enabled = local.vpc_cni_addon_enabled

  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

  service_account_name      = "aws-node"
  service_account_namespace = "kube-system"

  aws_iam_policy_document = [one(data.aws_iam_policy_document.vpc_cni_ipv6[*].json)]

  context = module.this.context
}

# `aws-ebs-csi-driver` EKS addon
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons
# https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#csi-iam-role
# https://github.com/kubernetes-sigs/aws-ebs-csi-driver
resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver" {
  count = local.aws_ebs_csi_driver_enabled ? 1 : 0

  role       = module.aws_ebs_csi_driver_eks_iam_role.service_account_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "aws_ebs_csi_driver_eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.0"

  enabled = local.aws_ebs_csi_driver_enabled

  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

  service_account_name      = "ebs-csi-controller"
  service_account_namespace = "kube-system"

  context = module.this.context
}

module "aws_ebs_csi_driver_fargate_profile" {
  count = local.aws_ebs_csi_driver_enabled && var.deploy_addons_to_fargate ? 1 : 0

  source  = "cloudposse/eks-fargate-profile/aws"
  version = "1.3.0"

  subnet_ids                              = local.private_subnet_ids
  cluster_name                            = module.eks_cluster.eks_cluster_id
  kubernetes_namespace                    = "kube-system"
  kubernetes_labels                       = { app = "ebs-csi-controller" }
  permissions_boundary                    = var.fargate_profile_iam_role_permissions_boundary
  iam_role_kubernetes_namespace_delimiter = var.fargate_profile_iam_role_kubernetes_namespace_delimiter

  fargate_profile_name               = "${module.eks_cluster.eks_cluster_id}-ebs-csi"
  fargate_pod_execution_role_enabled = false
  fargate_pod_execution_role_arn     = one(module.fargate_pod_execution_role[*].eks_fargate_pod_execution_role_arn)

  attributes = ["ebs-csi"]
  context    = module.this.context
}

module "coredns_fargate_profile" {
  count = local.coredns_enabled && var.deploy_addons_to_fargate ? 1 : 0

  source  = "cloudposse/eks-fargate-profile/aws"
  version = "1.3.0"


  subnet_ids                              = local.private_subnet_ids
  cluster_name                            = module.eks_cluster.eks_cluster_id
  kubernetes_namespace                    = "kube-system"
  kubernetes_labels                       = { k8s-app = "kube-dns" }
  permissions_boundary                    = var.fargate_profile_iam_role_permissions_boundary
  iam_role_kubernetes_namespace_delimiter = var.fargate_profile_iam_role_kubernetes_namespace_delimiter

  fargate_profile_name               = "${module.eks_cluster.eks_cluster_id}-coredns"
  fargate_pod_execution_role_enabled = false
  fargate_pod_execution_role_arn     = one(module.fargate_pod_execution_role[*].eks_fargate_pod_execution_role_arn)

  attributes = ["coredns"]
  context    = module.this.context
}
