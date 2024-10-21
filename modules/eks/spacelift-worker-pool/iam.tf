locals {
  identity_account_name = module.account_map.outputs.identity_account_account_name
  ecr_repo_arn          = module.ecr.outputs.ecr_repo_arn_map[var.ecr_repo_name]
  role_arn_template     = module.account_map.outputs.iam_role_arn_templates[local.identity_account_name]
}

data "aws_partition" "current" {}

module "eks_iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "2.0.1"

  enabled = local.kubernetes_service_account_enabled

  iam_source_policy_documents   = var.iam_source_policy_documents
  iam_override_policy_documents = var.iam_override_policy_documents
  iam_source_json_url           = var.iam_source_json_url

  iam_policy_enabled = true

  iam_policy = [{
    statements = [
      {
        sid    = "AssumeSpaceliftRole"
        effect = "Allow"
        actions = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
        resources = formatlist(local.role_arn_template, ["spacelift"])
      },
      {
        sid       = "ECRGetAuthorizationToken"
        effect    = "Allow"
        actions   = ["ecr:GetAuthorizationToken"]
        resources = ["*"]
      },
      {
        sid    = "ECRRepoPermissions"
        effect = "Allow"
        actions = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        resources = [local.ecr_repo_arn]
      }
    ]
  }]

  attributes = var.iam_attributes
  context    = module.this.context
}

module "eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.1"

  enabled = local.kubernetes_service_account_enabled

  aws_iam_policy_document     = [module.eks_iam_policy.json]
  aws_partition               = data.aws_partition.current.partition
  eks_cluster_oidc_issuer_url = local.eks_cluster_identity_oidc_issuer
  service_account_name        = var.kubernetes_service_account_name
  service_account_namespace   = var.kubernetes_namespace
  permissions_boundary        = var.iam_permissions_boundary

  attributes = var.iam_attributes
  context    = module.this.context

  depends_on = [module.eks_iam_policy]
}
