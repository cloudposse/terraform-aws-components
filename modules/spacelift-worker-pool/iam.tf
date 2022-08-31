module "iam_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = var.iam_attributes

  context = module.this.context
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  partition = one(data.aws_partition.current[*].partition)

  role_arn_template_template = "arn:%[4]s:iam::%[3]s:role/%[1]s${module.this.tenant == null ? "" : "-%[2]s"}-gbl-identity-%%s"

  role_arn_template = format(local.role_arn_template_template, module.this.namespace, module.this.tenant, local.identity_account_id, local.partition)
}

data "aws_iam_policy_document" "default" {
  count = local.enabled ? 1 : 0

  statement {
    actions   = ["sts:AssumeRole"]
    resources = formatlist(local.role_arn_template, ["ops", "spacelift"])
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
  policy = join("", data.aws_iam_policy_document.default.*.json)

  tags = module.iam_label.tags
}

resource "aws_iam_role" "default" {
  count = local.enabled ? 1 : 0

  name               = module.iam_label.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_policy.*.json)
  managed_policy_arns = [
    join("", aws_iam_policy.default.*.arn),
    "arn:${join("", data.aws_partition.current.*.partition)}:iam::aws:policy/AutoScalingReadOnlyAccess",
    "arn:${join("", data.aws_partition.current.*.partition)}:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:${join("", data.aws_partition.current.*.partition)}:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:${join("", data.aws_partition.current.*.partition)}:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]

  tags = module.iam_label.tags
}

resource "aws_iam_instance_profile" "default" {
  count = local.enabled ? 1 : 0

  name = module.iam_label.id
  role = join("", aws_iam_role.default.*.name)

  tags = module.iam_label.tags
}
