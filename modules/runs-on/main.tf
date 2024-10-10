locals {
  enabled = module.this.enabled

  parameters = merge({
    "EC2InstanceCustomPolicy" = module.iam_policy.policy_arn
  }, var.parameters)

}

module "iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "v2.0.1"

  context = module.this.context
  enabled = module.this.enabled

  iam_policy_enabled = true
  iam_policy = [
    {
      version   = "2012-10-17"
      policy_id = "example"
      statements = [
        {
          sid    = "AllowECRActions"
          effect = "Allow"
          actions = [
            "ecr:UploadLayerPart",
            "ecr:UntagResource",
            "ecr:TagResource",
            "ecr:StartLifecyclePolicyPreview",
            "ecr:StartImageScan",
            "ecr:PutLifecyclePolicy",
            "ecr:PutImageTagMutability",
            "ecr:PutImageScanningConfiguration",
            "ecr:PutImage",
            "ecr:ListImages",
            "ecr:InitiateLayerUpload",
            "ecr:GetRepositoryPolicy",
            "ecr:GetLifecyclePolicyPreview",
            "ecr:GetLifecyclePolicy",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken",
            "ecr:DescribeRepositories",
            "ecr:DescribeImages",
            "ecr:DescribeImageScanFindings",
            "ecr:DeleteLifecyclePolicy",
            "ecr:CompleteLayerUpload",
            "ecr:BatchGetImage",
            "ecr:BatchDeleteImage",
            "ecr:BatchCheckLayerAvailability",
          ]
          resources = ["*"]
        }
      ]
    }
  ]
}

module "cloudformation_stack" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/cloudformation-stack/aws"
  version = "v0.7.1"

  enabled = var.enabled
  context = module.this.context

  template_url       = var.template_url
  parameters         = local.parameters
  capabilities       = var.capabilities
  on_failure         = var.on_failure
  timeout_in_minutes = var.timeout_in_minutes
  policy_body        = var.policy_body

  depends_on = [module.iam_policy]
}

locals {
  vpc_id         = one(module.cloudformation_stack[*].outputs["RunsOnVPCId"])
  vpc_cidr_block = one(module.cloudformation_stack[*].outputs["RunsOnVpcCidrBlock"])
  public_subnet_ids = compact([
    one(module.cloudformation_stack[*].outputs["RunsOnPublicSubnet1"]),
    one(module.cloudformation_stack[*].outputs["RunsOnPublicSubnet2"]),
    one(module.cloudformation_stack[*].outputs["RunsOnPublicSubnet3"]),
  ])
  private_subnet_ids = compact([
    one(module.cloudformation_stack[*].outputs["RunsOnPrivateSubnet1"]),
    one(module.cloudformation_stack[*].outputs["RunsOnPrivateSubnet2"]),
    one(module.cloudformation_stack[*].outputs["RunsOnPrivateSubnet3"]),
  ])
  private_route_table_ids = compact([
    one(module.cloudformation_stack[*].outputs["RunsOnPrivateRouteTable1Id"]),
    one(module.cloudformation_stack[*].outputs["RunsOnPrivateRouteTable2Id"]),
    one(module.cloudformation_stack[*].outputs["RunsOnPrivateRouteTable3Id"]),
  ])
}

data "aws_nat_gateways" "ngws" {
  count  = local.enabled ? 1 : 0
  vpc_id = local.vpc_id
}
