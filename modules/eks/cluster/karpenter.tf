# IAM Role for EC2 instance profile that is assigned to EKS worker nodes launched by Karpenter

# https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler/
# https://karpenter.sh/
# https://karpenter.sh/v0.10.1/getting-started/getting-started-with-terraform/
# https://karpenter.sh/v0.10.1/getting-started/getting-started-with-eksctl/
# https://www.eksworkshop.com/beginner/085_scaling_karpenter/
# https://karpenter.sh/v0.10.1/aws/provisioning/
# https://www.eksworkshop.com/beginner/085_scaling_karpenter/setup_the_environment/
# https://ec2spotworkshops.com/karpenter.html
# https://catalog.us-east-1.prod.workshops.aws/workshops/76a5dd80-3249-4101-8726-9be3eeee09b2/en-US/autoscaling/karpenter

locals {
  karpenter_iam_role_enabled = local.enabled && var.karpenter_iam_role_enabled

  karpenter_instance_profile_enabled = local.karpenter_iam_role_enabled && !var.legacy_do_not_create_karpenter_instance_profile

  # Used to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = one(data.aws_partition.current[*].partition)
}

data "aws_partition" "current" {
  count = local.karpenter_iam_role_enabled ? 1 : 0
}

module "karpenter_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled    = local.karpenter_iam_role_enabled
  attributes = ["karpenter"]

  context = module.this.context
}

data "aws_iam_policy_document" "assume_role" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role for EC2 instance profile that is assigned to EKS worker nodes launched by Karpenter
resource "aws_iam_role" "karpenter" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  name               = module.karpenter_label.id
  description        = "IAM Role for EC2 instance profile that is assigned to EKS worker nodes launched by Karpenter"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = module.karpenter_label.tags
}

resource "aws_iam_instance_profile" "default" {
  count = local.karpenter_instance_profile_enabled ? 1 : 0

  name = one(aws_iam_role.karpenter[*].name)
  role = one(aws_iam_role.karpenter[*].name)
  tags = module.karpenter_label.tags
}

# AmazonSSMManagedInstanceCore policy is required by Karpenter
resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  role       = one(aws_iam_role.karpenter[*].name)
  policy_arn = format("arn:%s:iam::aws:policy/AmazonSSMManagedInstanceCore", local.partition)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  role       = one(aws_iam_role.karpenter[*].name)
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSWorkerNodePolicy", local.partition)
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_readonly" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  role       = one(aws_iam_role.karpenter[*].name)
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", local.partition)
}

# Create a CNI policy that is a merger of AmazonEKS_CNI_Policy and required IPv6 permissions
# https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy
data "aws_iam_policy_document" "ipv6_eks_cni_policy" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:AssignPrivateIpAddresses",
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:${local.partition}:ec2:*:*:network-interface/*"
    ]
  }
}

resource "aws_iam_policy" "ipv6_eks_cni_policy" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  name        = "${module.this.id}-CNI_Policy"
  description = "CNI policy that is a merger of AmazonEKS_CNI_Policy and required IPv6 permissions"
  policy      = data.aws_iam_policy_document.ipv6_eks_cni_policy[0].json
  tags        = module.karpenter_label.tags
}

resource "aws_iam_role_policy_attachment" "ipv6_eks_cni_policy" {
  count = local.karpenter_iam_role_enabled ? 1 : 0

  role       = one(aws_iam_role.karpenter[*].name)
  policy_arn = one(aws_iam_policy.ipv6_eks_cni_policy[*].arn)
}
