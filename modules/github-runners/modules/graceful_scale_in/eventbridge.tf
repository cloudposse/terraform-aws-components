locals {
  automation_definition_arn = "arn:${join("", data.aws_partition.current.*.partition)}:ssm:${join("", data.aws_region.current.*.name)}:${join("", data.aws_caller_identity.current.*.account_id)}:automation-definition/${join("", aws_ssm_document.default.*.name)}:$DEFAULT"
}

module "eventbridge_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.enabled

  attributes = ["eventbridge"]

  context = module.this.context
}

data "aws_iam_policy_document" "eventbridge_assume_role_policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eventbridge_policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      local.automation_definition_arn
    ]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      join("", aws_iam_role.ssm_document_role.*.arn)
    ]
  }
}

resource "aws_iam_policy" "eventbridge_policy" {
  count = local.enabled ? 1 : 0

  name   = module.eventbridge_label.id
  policy = join("", data.aws_iam_policy_document.eventbridge_policy.*.json)
}

resource "aws_iam_role" "eventbridge_role" {
  count = local.enabled ? 1 : 0

  name                = module.eventbridge_label.id
  tags                = module.eventbridge_label.tags
  assume_role_policy  = join("", data.aws_iam_policy_document.eventbridge_assume_role_policy.*.json)
  managed_policy_arns = [join("", aws_iam_policy.eventbridge_policy.*.arn)]
}

resource "aws_cloudwatch_event_rule" "default" {
  count = local.enabled ? 1 : 0

  name        = module.eventbridge_label.id
  description = "Auto Scaling Group EC2 Instance Termination"

  event_pattern = jsonencode({
    source = [
      "aws.autoscaling"
    ]
    detail-type : [
      "EC2 Instance-terminate Lifecycle Action"
    ]
    detail : {
      AutoScalingGroupName : [
        var.autoscaling_group_name
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "default" {
  count = local.enabled ? 1 : 0

  rule      = join("", aws_cloudwatch_event_rule.default.*.name)
  target_id = module.this.id
  arn       = local.automation_definition_arn
  role_arn  = join("", aws_iam_role.eventbridge_role.*.arn)
  input_transformer {
    input_paths = {
      "asgname" : "$.detail.AutoScalingGroupName",
      "instanceid" : "$.detail.EC2InstanceId",
      "lchname" : "$.detail.LifecycleHookName"
    }
    input_template = <<-EOF
    {
      "InstanceId": [
        <instanceid>
      ],
      "ASGName": [
        <asgname>
      ],
      "LCHName": [
        <lchname>
      ],
      "automationAssumeRole": [
        "${join("", aws_iam_role.ssm_document_role.*.arn)}"
      ]
    }
    EOF
  }
}