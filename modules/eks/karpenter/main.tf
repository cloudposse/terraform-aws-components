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
  enabled = module.this.enabled

  eks_cluster_identity_oidc_issuer = try(module.eks.outputs.eks_cluster_identity_oidc_issuer, "")
  karpenter_iam_role_name          = try(module.eks.outputs.karpenter_iam_role_name, "")

  karpenter_instance_profile_enabled = local.enabled && var.legacy_create_karpenter_instance_profile && length(local.karpenter_iam_role_name) > 0
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

resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name        = var.kubernetes_namespace
    annotations = {}
    labels      = merge(module.this.tags, { name = var.kubernetes_namespace })
  }
}

# Deploy karpenter-crd helm chart
# "karpenter-crd" can be installed as an independent helm chart to manage the lifecycle of Karpenter CRDs
module "karpenter_crd" {
  enabled = local.enabled && var.crd_chart_enabled

  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name            = var.crd_chart
  chart           = var.crd_chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = false # Namespace is created with kubernetes_namespace resources to be shared between charts
  kubernetes_namespace             = join("", kubernetes_namespace.default[*].id)
  kubernetes_namespace_labels      = merge(module.this.tags, { name = join("", kubernetes_namespace.default[*].id) })

  eks_cluster_oidc_issuer_url = coalesce(replace(local.eks_cluster_identity_oidc_issuer, "https://", ""), "deleted")

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name
      resources        = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
  ])

  context = module.this.context

  depends_on = [
    kubernetes_namespace.default
  ]
}

# Deploy Karpenter helm chart
module "karpenter" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  chart           = var.chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = false # Namespace is created with kubernetes_namespace resources to be shared between charts
  kubernetes_namespace             = join("", kubernetes_namespace.default[*].id)
  kubernetes_namespace_labels      = merge(module.this.tags, { name = join("", kubernetes_namespace.default[*].id) })

  eks_cluster_oidc_issuer_url = coalesce(replace(local.eks_cluster_identity_oidc_issuer, "https://", ""), "deleted")

  service_account_name      = module.this.name
  service_account_namespace = join("", kubernetes_namespace.default[*].id)

  iam_role_enabled = true

  # https://karpenter.sh/v0.6.1/getting-started/cloudformation.yaml
  # https://karpenter.sh/v0.10.1/getting-started/getting-started-with-terraform
  # https://github.com/aws/karpenter/issues/2649
  # Apparently the source of truth for the best IAM policy is the `data.aws_iam_policy_document.karpenter_controller` in
  # https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/modules/iam-role-for-service-accounts-eks/policies.tf
  iam_policy = [{
    statements = concat([
      {
        sid       = "KarpenterController"
        effect    = "Allow"
        resources = ["*"]

        actions = [
          # https://github.com/terraform-aws-modules/terraform-aws-iam/blob/99c69ad54d985f67acf211885aa214a3a6cc931c/modules/iam-role-for-service-accounts-eks/policies.tf#L511-L581
          # The reference policy is broken up into multiple statements with different resource restrictions based on tags.
          # This list has breaks where statements are separated in the reference policy for easier comparison and maintenance.
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:CreateTags",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts",

          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",

          "ec2:RunInstances",

          "iam:PassRole",
        ]
      },
      {
        sid    = "KarpenterControllerSSM"
        effect = "Allow"
        # Allow Karpenter to read AMI IDs from SSM
        actions   = ["ssm:GetParameter"]
        resources = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
      },
      {
        sid    = "KarpenterControllerClusterAccess"
        effect = "Allow"
        actions = [
          "eks:DescribeCluster"
        ]
        resources = [
          module.eks.outputs.eks_cluster_arn
        ]
      }
      ],
      local.interruption_handler_enabled ? [
        {
          sid    = "KarpenterInterruptionHandlerAccess"
          effect = "Allow"
          actions = [
            "sqs:DeleteMessage",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes",
            "sqs:ReceiveMessage",
          ]
          resources = [
            one(aws_sqs_queue.interruption_handler[*].arn)
          ]
        }
      ] : []
    )
  }]


  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name
      serviceAccount = {
        name = module.this.name
      }
      controller = {
        resources = var.resources
      }
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # karpenter-specific values
    yamlencode({
      settings = {
        # This configuration of settings requires Karpenter chart v0.19.0 or later
        aws = {
          defaultInstanceProfile = local.karpenter_iam_role_name # instance profile name === role name
          clusterName            = local.eks_cluster_id
          # clusterEndpoint not needed as of v0.25.0
          clusterEndpoint = local.eks_cluster_endpoint
          tags            = module.this.tags
        }
      }
    }),
    yamlencode(
      local.interruption_handler_enabled ? {
        settings = {
          aws = {
            interruptionQueueName = local.interruption_handler_queue_name
          }
        }
    } : {}),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context

  depends_on = [
    aws_iam_instance_profile.default,
    module.karpenter_crd,
    kubernetes_namespace.default
  ]
}
