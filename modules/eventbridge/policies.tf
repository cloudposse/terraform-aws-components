
# Note, we need to allow the eventbridge to write to cloudwatch logs
# we use aws_cloudwatch_log_resource_policy to do this

locals {
  log_group_arn = one(module.cloudwatch_logs[*].log_group_arn)
}
data "aws_iam_policy_document" "eventbridge_cloudwatch_logs_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com",
      ]
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${local.log_group_arn}:*",
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "eventbridge_cloudwatch_logs_policy" {
  count           = local.enabled ? 1 : 0
  policy_document = data.aws_iam_policy_document.eventbridge_cloudwatch_logs_policy.json
  policy_name     = module.this.id
}
