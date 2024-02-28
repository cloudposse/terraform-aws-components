locals {
  aws_account_id  = module.this.enabled ? data.aws_caller_identity.current[0].id : ""
  aws_region_name = module.this.enabled ? data.aws_region.current[0].name : ""

  # Documentation: https://karpenter.sh/v0.34/reference/cloudformation/#controller-authorization
  controller_policy_statements = [
    for x in [
      {
        sid    = "AllowScopedEC2InstanceAccessActions",
        effect = "Allow",
        actions = [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
        resources = [
          "arn:aws:ec2:${local.aws_region_name}::image/*",
          "arn:aws:ec2:${local.aws_region_name}::snapshot/*",
          "arn:aws:ec2:${local.aws_region_name}:*:security-group/*",
          "arn:aws:ec2:${local.aws_region_name}:*:subnet/*"
        ],
      },
      {
        sid    = "AllowScopedEC2LaunchTemplateAccessActions",
        effect = "Allow",
        actions = [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ],
        resources = ["arn:aws:ec2:${local.aws_region_name}:*:launch-template/*"],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringLike",
            variable = "aws:ResourceTag/karpenter.sh/nodepool",
            values   = ["*"],
          },
        ]
      },
      {
        sid    = "AllowScopedEC2InstanceActionsWithTags",
        effect = "Allow",
        actions = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate"
        ],
        resources = [
          "arn:aws:ec2:${local.aws_region_name}:*:fleet/*",
          "arn:aws:ec2:${local.aws_region_name}:*:instance/*",
          "arn:aws:ec2:${local.aws_region_name}:*:volume/*",
          "arn:aws:ec2:${local.aws_region_name}:*:network-interface/*",
          "arn:aws:ec2:${local.aws_region_name}:*:launch-template/*",
          "arn:aws:ec2:${local.aws_region_name}:*:spot-instances-request/*"
        ],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:RequestTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringLike",
            variable = "aws:RequestTag/karpenter.sh/nodepool",
            values   = ["*"],
          },
        ]
      },
      {
        sid     = "AllowScopedResourceCreationTagging",
        effect  = "Allow",
        actions = ["ec2:CreateTags"],
        resources = [
          "arn:aws:ec2:${local.aws_region_name}:*:fleet/*",
          "arn:aws:ec2:${local.aws_region_name}:*:instance/*",
          "arn:aws:ec2:${local.aws_region_name}:*:volume/*",
          "arn:aws:ec2:${local.aws_region_name}:*:network-interface/*",
          "arn:aws:ec2:${local.aws_region_name}:*:launch-template/*",
          "arn:aws:ec2:${local.aws_region_name}:*:spot-instances-request/*"
        ],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:RequestTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringEquals",
            variable = "ec2:CreateAction",
            values   = ["RunInstances", "CreateFleet", "CreateLaunchTemplate"],
          },
          {
            test     = "StringLike",
            variable = "aws:RequestTag/karpenter.sh/nodepool",
            values   = ["*"],
          },
        ]
      },
      {
        sid       = "AllowScopedResourceTagging",
        effect    = "Allow",
        actions   = ["ec2:CreateTags"],
        resources = ["arn:aws:ec2:${local.aws_region_name}:*:instance/*"],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringLike",
            variable = "aws:ResourceTag/karpenter.sh/nodepool",
            values   = ["*"],
          },
          {
            test     = "ForAllValues:StringEquals",
            variable = "aws:TagKeys",
            values   = ["karpenter.sh/nodeclaim", "Name"],
          },
        ]
      },
      {
        sid    = "AllowScopedDeletion",
        effect = "Allow",
        actions = [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ],
        resources = [
          "arn:aws:ec2:${local.aws_region_name}:*:instance/*",
          "arn:aws:ec2:${local.aws_region_name}:*:launch-template/*"
        ],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringLike",
            variable = "aws:ResourceTag/karpenter.sh/nodepool",
            values   = ["*"],
          },
        ]
      },
      {
        sid    = "AllowRegionalReadActions",
        effect = "Allow",
        actions = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets"
        ],
        resources = ["*"],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:RequestedRegion",
            values   = [local.aws_region_name]
          },
        ]
      },
      {
        sid       = "AllowSSMReadActions",
        effect    = "Allow",
        actions   = ["ssm:GetParameter"],
        resources = ["arn:aws:ssm:${local.aws_region_name}::parameter/aws/service/*"],
      },
      {
        sid       = "AllowPricingReadActions",
        effect    = "Allow",
        actions   = ["pricing:GetProducts"],
        resources = ["*"],
      },
      {
        sid       = "AllowPassingInstanceRole",
        effect    = "Allow",
        actions   = ["iam:PassRole"],
        resources = [local.karpenter_iam_role_arn],
        conditions = [
          {
            test     = "StringEquals",
            variable = "iam:PassedToService",
            values   = ["ec2.amazonaws.com"]
          },
        ]
      },
      {
        sid       = "AllowScopedInstanceProfileCreationActions",
        effect    = "Allow",
        actions   = ["iam:CreateInstanceProfile"],
        resources = ["*"],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:RequestTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringEquals",
            variable = "aws:RequestTag/topology.kubernetes.io/region",
            values   = [local.aws_region_name],
          },
          {
            test     = "StringLike",
            variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass",
            values   = ["*"],
          },
        ]
      },
      {
        sid       = "AllowScopedInstanceProfileTagActions",
        effect    = "Allow",
        actions   = ["iam:TagInstanceProfile"],
        resources = ["*"],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/topology.kubernetes.io/region",
            values   = [local.aws_region_name],
          },
          {
            test     = "StringEquals",
            variable = "aws:RequestTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringEquals",
            variable = "aws:RequestTag/topology.kubernetes.io/region",
            values   = [local.aws_region_name],
          },
          {
            test     = "StringLike",
            variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass",
            values   = ["*"],
          },
          {
            test     = "StringLike",
            variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass",
            values   = ["*"],
          }
        ]
      },
      {
        sid    = "AllowScopedInstanceProfileActions",
        effect = "Allow",
        actions = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        resources = ["*"],
        conditions = [
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}",
            values   = ["owned"],
          },
          {
            test     = "StringEquals",
            variable = "aws:ResourceTag/topology.kubernetes.io/region",
            values   = [local.aws_region_name],
          },
          {
            test     = "StringLike",
            variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass",
            values   = ["*"],
          },
        ]
      },
      {
        sid       = "AllowInstanceProfileReadActions",
        effect    = "Allow",
        actions   = ["iam:GetInstanceProfile"],
        resources = ["*"],
      },
      {
        sid       = "AllowAPIServerEndpointDiscovery",
        effect    = "Allow",
        actions   = ["eks:DescribeCluster"],
        resources = ["arn:aws:eks:${local.aws_region_name}:${local.aws_account_id}:cluster/${local.eks_cluster_id}"],
      },
      local.interruption_handler_enabled ? {
        sid    = "AllowInterruptionQueueActions",
        effect = "Allow",
        actions = [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ]
        resources = [aws_sqs_queue.interruption_handler[0].arn],
      } : null,
    ] : x if x != null && module.this.enabled
  ]
}

data "aws_caller_identity" "current" {
  count = module.this.enabled ? 1 : 0
}

data "aws_region" "current" {
  count = module.this.enabled ? 1 : 0
}

resource "aws_iam_instance_profile" "default" {
  count = local.karpenter_instance_profile_enabled ? 1 : 0

  name = local.karpenter_iam_role_name
  role = local.karpenter_iam_role_name
  tags = module.this.tags
}

# See CHANGELOG for PR #868:
# https://github.com/cloudposse/terraform-aws-components/pull/868
#
# Namespace was moved from the karpenter module to an independent resource in order to be
# shared between both the karpenter and karpenter-crd modules.
moved {
  from = module.karpenter.kubernetes_namespace.default[0]
  to   = kubernetes_namespace.default[0]
}
