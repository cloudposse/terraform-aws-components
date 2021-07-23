# IAM permissions for the Jenkins master, mainly to read credentials from Secrets Manager

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
