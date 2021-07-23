# IAM permissions for the Jenkins master, mainly to read credentials from Secrets Manager

# variable "authorize_cluster_workers_as_jenkins" {
#   type        = bool
#   default     = false
#   description = "Set true to set all workers to be able to act as Jenkins"
# }

# locals {
#   jenkins-operator-jenkins_enabled          = try(index(local.service_account_list, "jenkins-operator-jenkins"), -1) >= 0
#   jenkins-operator-jenkins_authorized_roles = toset(var.authorize_cluster_workers_as_jenkins ? local.eks_outputs.eks_node_group_role_names : [])
# }

module "jenkins-operator-jenkins" {
  source                    = "./modules/service-account"

  service_account_name      = "jenkins-operator-jenkins"
  service_account_namespace = "jenkins"
  aws_iam_policy_document = join("", data.aws_iam_policy_document.jenkins-operator-jenkins.*.json)

  cluster_context = local.cluster_context
  context         = module.this.context
}

data "aws_iam_policy_document" "jenkins-operator-jenkins" {
  statement {
    sid = "ReadSecrets"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    effect = "Allow"
    # resources = ["*"]
    resources = [
      "arn:aws:secretsmanager:*:498979307932:secret:*",
    ]

    # Limit Jenkins to secrets tagged for Jenkins
    condition {
      test     = "Null"
      values   = ["false"]
      variable = "secretsmanager:ResourceTag/jenkins:credentials:type"
    }

  }

  statement {
    sid = "ListSecrets"

    actions = [
      "secretsmanager:ListSecrets"
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}
