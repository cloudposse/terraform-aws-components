variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook URL"
}

variable "slack_channel" {
  type        = string
  description = "Slack channel"
}

variable "slack_username" {
  type        = string
  description = "Slack username"
}

module "sns_topic_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  name       = "sns"
  namespace  = var.namespace
  stage      = var.stage
  attributes = compact(concat(var.attributes, ["alarms"]))
}

# Create an SNS topic
resource "aws_sns_topic" "default" {
  name_prefix = module.sns_topic_label.id
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.default.arn
  policy = data.aws_iam_policy_document.sns_topic.json
}

data "aws_caller_identity" "default" {
}

data "aws_iam_policy_document" "sns_topic" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]

    effect    = "Allow"
    resources = [aws_sns_topic.default.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.default.account_id
      ]
    }
  }

  statement {
    sid       = "Allow CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.default.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

module "notify_slack" {
  source            = "git::https://github.com/cloudposse/terraform-aws-sns-lambda-notify-slack?ref=tags/0.3.0"
  name              = "slack"
  namespace         = var.namespace
  stage             = var.stage
  create_sns_topic  = false
  sns_topic_name    = aws_sns_topic.default.name
  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username
}
