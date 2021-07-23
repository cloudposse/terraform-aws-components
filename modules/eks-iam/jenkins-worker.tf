# IAM permisions for the Jenkins executor workers, mainly to push Docker images

variable "ecr_registry_arn" {
  type        = string
  description = "ECR registry (not repo) ARN, like arn:aws:ecr:us-east-1:123456789012:repository"
}

module "jenkins-worker" {
  source                    = "./modules/service-account"

  service_account_name      = "jenkins-worker"
  service_account_namespace = "jenkins"
  aws_iam_policy_document = join("", data.aws_iam_policy_document.jenkins-worker.*.json)

  cluster_context = local.cluster_context
  context         = module.this.context
}

data "aws_iam_policy_document" "jenkins-worker" {
  statement {
    sid = "ManageRepositoryContents"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    effect    = "Allow"
    resources = ["${var.ecr_registry_arn}/*"]
  }

  statement {
    sid = "GetAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  # TODO: create a primary role for Jenkins
  # statement {
  #   sid = "AssumeRoles"

  #   actions = ["sts:AssumeRole"]

  #   effect = "Allow"
  #   resources = [
  #     try(data.terraform_remote_state.iam-primary-roles[0].outputs.iam-primary-roles.role_name_role_arn_map["jenkins"],
  #     data.terraform_remote_state.iam-primary-roles[0].outputs.role_name_role_arn_map["jenkins"])
  #   ]
  # }
}
