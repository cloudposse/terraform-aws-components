module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${module.label.id}"
  retention_in_days = "${var.cloudwatch_logs_retention_in_days}"
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    sid = "AWSCloudTrail"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:${local.region}:${data.aws_caller_identity.default.account_id}:log-group:${aws_cloudwatch_log_group.default.name}:log-stream:*"]
    effect    = "Allow"
  }
}

module "cloudwatch_logs_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"

  enabled   = "true"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes  = ["cloudwatch", "logs"]

  principals = {
    Service = ["cloudtrail.amazonaws.com"]
  }

  policy_documents = [
    "${data.aws_iam_policy_document.cloudwatch_logs.json}"
  ]
}
