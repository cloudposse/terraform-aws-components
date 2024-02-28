module "iam_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = var.iam_attributes

  context = module.this.context
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  identity_account_name = module.account_map.outputs.identity_account_account_name
  role_arn_template     = module.account_map.outputs.iam_role_arn_templates[local.identity_account_name]
}

data "aws_iam_policy_document" "default" {
  count = local.enabled ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]
    resources = formatlist(local.role_arn_template, ["spacelift"])
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [local.ecr_repo_arn]
  }
}

resource "aws_iam_policy" "default" {
  count = local.enabled ? 1 : 0

  name   = module.iam_label.id
  policy = join("", data.aws_iam_policy_document.default[*].json)

  tags = module.iam_label.tags
}

resource "aws_iam_role" "default" {
  count = local.enabled ? 1 : 0

  name               = module.iam_label.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_policy[*].json)
  managed_policy_arns = [
    join("", aws_iam_policy.default[*].arn),
    "arn:${join("", data.aws_partition.current[*].partition)}:iam::aws:policy/AutoScalingReadOnlyAccess",
    "arn:${join("", data.aws_partition.current[*].partition)}:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:${join("", data.aws_partition.current[*].partition)}:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:${join("", data.aws_partition.current[*].partition)}:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]

  tags = module.iam_label.tags
}

resource "aws_iam_instance_profile" "default" {
  count = local.enabled ? 1 : 0

  name = module.iam_label.id
  role = join("", aws_iam_role.default[*].name)

  tags = module.iam_label.tags
}
