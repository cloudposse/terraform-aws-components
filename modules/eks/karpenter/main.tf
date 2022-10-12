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
  enabled                          = module.this.enabled
  create_namespace                 = local.enabled && var.create_namespace
  eks_cluster_identity_oidc_issuer = module.eks.outputs.eks_cluster_identity_oidc_issuer
  karpenter_iam_role_name          = module.eks.outputs.karpenter_iam_role_name
}

resource "aws_iam_instance_profile" "default" {
  count = local.enabled ? 1 : 0

  name = local.karpenter_iam_role_name
  role = local.karpenter_iam_role_name
  tags = module.this.tags
}

# Create Karpenter Kubernetes namespace
resource "kubernetes_namespace" "default" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name        = var.kubernetes_namespace
    annotations = {}
    labels      = module.this.tags
  }
}

# Deploy Karpenter helm chart
module "karpenter" {
  source  = "cloudposse/helm-release/aws"
  version = "0.5.0"

  chart                = var.chart
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = local.create_namespace ? one(kubernetes_namespace.default[*].id) : var.kubernetes_namespace
  create_namespace     = false
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = replace(local.eks_cluster_identity_oidc_issuer, "https://", "")

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled = true

  # https://karpenter.sh/v0.6.1/getting-started/cloudformation.yaml
  # https://karpenter.sh/v0.10.1/getting-started/getting-started-with-terraform
  iam_policy_statements = [
    {
      sid       = "KarpenterController"
      effect    = "Allow"
      resources = ["*"]

      actions = [
        "ec2:CreateLaunchTemplate",
        "ec2:CreateFleet",
        "ec2:RunInstances",
        "ec2:CreateTags",
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeAvailabilityZones",
        "ssm:GetParameter",
        "iam:PassRole"
      ]
    }
  ]

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name
      serviceAccount = {
        name = module.this.name
      }
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # karpenter-specific values
    yamlencode({
      aws = {
        defaultInstanceProfile = one(aws_iam_instance_profile.default[*].name)
      }
      clusterName     = local.eks_cluster_id
      clusterEndpoint = local.eks_cluster_endpoint
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
