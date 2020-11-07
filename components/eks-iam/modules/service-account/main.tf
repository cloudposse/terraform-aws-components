module "eks_iam_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-eks-iam-role.git?ref=tags/0.3.1"

  enabled = contains(var.cluster_context.service_account_list, var.service_account_name) && module.this.enabled

  aws_account_number          = var.cluster_context.aws_account_number
  eks_cluster_oidc_issuer_url = var.cluster_context.eks_cluster_oidc_issuer_url

  service_account_name      = var.service_account_name
  service_account_namespace = var.service_account_namespace
  aws_iam_policy_document   = var.aws_iam_policy_document

  context = module.this.context
}
