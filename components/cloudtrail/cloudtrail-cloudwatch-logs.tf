data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail_cloudwatch_logs.arn}:*"
    ]
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_logs" {
  name                 = module.this.id
  assume_role_policy   = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs_assume_role.json
  description          = "Allow CloudTrail to write to CloudWatch Logs"
  max_session_duration = var.cloudtrail_cloudwatch_logs_role_max_session_duration
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name        = module.this.id
  description = "Allow CloudTrail to write to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch_logs" {
  role       = aws_iam_role.cloudtrail_cloudwatch_logs.name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs.arn
}

resource "aws_cloudwatch_log_group" "cloudtrail_cloudwatch_logs" {
  name              = module.this.id
  retention_in_days = var.cloudwatch_logs_retention_in_days
  tags              = module.this.tags
}
