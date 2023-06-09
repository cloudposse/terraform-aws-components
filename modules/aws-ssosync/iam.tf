
data "aws_iam_policy_document" "ssosync_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssosync_lambda_identity_center" {
  statement {
    effect = "Allow"
    actions = [
      "identitystore:DeleteUser",
      "identitystore:CreateGroup",
      "identitystore:CreateGroupMembership",
      "identitystore:ListGroups",
      "identitystore:ListUsers",
      "identitystore:ListGroupMemberships",
      "identitystore:IsMemberInGroups",
      "identitystore:GetGroupMembershipId",
      "identitystore:DeleteGroupMembership",
      "identitystore:DeleteGroup",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "default" {
  count = local.enabled ? 1 : 0

  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.ssosync_lambda_assume_role.json

  inline_policy {
    name   = "ssosync_lambda_identity_center"
    policy = data.aws_iam_policy_document.ssosync_lambda_identity_center.json
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count = local.enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.default[0].name
}