locals {
  # The CompleteLifeCycle Action requires a wildcard in the Auto Scaling Group ARN, so we cannot reference the aws_autoscaling_group data source directly
  asg_wildcard_arn = "arn:${join("", data.aws_partition.current.*.partition)}:autoscaling:${join("", data.aws_region.current.*.name)}:${join("", data.aws_caller_identity.current.*.account_id)}:autoScalingGroup:*:autoScalingGroupName/${join("", data.aws_autoscaling_group.default.*.name)}"
}

module "ssm_document_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.enabled

  attributes = ["ssm", "doc"]

  context = module.this.context
}

data "aws_iam_policy_document" "ssm_document_assume_role_policy" {
  count = local.enabled ? 1 : 0

  statement {
    sid     = "AllowSSMAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

# https://aws.amazon.com/blogs/infrastructure-and-automation/run-code-before-terminating-an-ec2-auto-scaling-instance/
data "aws_iam_policy_document" "ssm_document_policy" {
  count = local.enabled ? 1 : 0

  statement {
    sid     = "AllowCompleteLifecycleAction"
    actions = ["autoscaling:CompleteLifecycleAction"]
    resources = [
      local.asg_wildcard_arn
    ]
  }

  statement {
    sid = "AllowListSSMCommands"
    actions = [
      "ssm:DescribeInstanceInformation",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid     = "AllowSendSSMCommandShellScript"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:${join("", data.aws_partition.current.*.partition)}:ssm:${join("", data.aws_region.current.*.name)}::document/AWS-RunShellScript"
    ]
  }

  statement {
    sid     = "AllowSendSSMCommandInstances"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:${join("", data.aws_partition.current.*.partition)}:ec2:*:*:instance/*"
    ]
  }
}

resource "aws_iam_policy" "ssm_document_policy" {
  count = local.enabled ? 1 : 0

  name   = module.ssm_document_label.id
  policy = join("", data.aws_iam_policy_document.ssm_document_policy.*.json)
}

resource "aws_iam_role" "ssm_document_role" {
  count = local.enabled ? 1 : 0

  name                = module.ssm_document_label.id
  tags                = module.ssm_document_label.tags
  assume_role_policy  = join("", data.aws_iam_policy_document.ssm_document_assume_role_policy.*.json)
  managed_policy_arns = [join("", aws_iam_policy.ssm_document_policy.*.arn)]
}
