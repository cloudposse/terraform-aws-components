module "kops_ecr_user" {
  source    = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=tags/0.3.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "cicd"

  tags = "${module.label.tags}"
}

data "aws_iam_policy_document" "login" {
  statement {
    sid       = "ECRGetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "login" {
  name   = "${module.label.id}"
  policy = "${data.aws_iam_policy_document.login.json}"
}

resource "aws_iam_user_policy_attachment" "user_login" {
  user       = "${module.kops_ecr_user.user_name}"
  policy_arn = "${aws_iam_policy.login.arn}"
}

output "kops_ecr_user_name" {
  value       = "${module.kops_ecr_user.user_name}"
  description = "Normalized IAM user name"
}

output "kops_ecr_user_arn" {
  value       = "${module.kops_ecr_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "kops_ecr_user_unique_id" {
  value       = "${module.kops_ecr_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "kops_ecr_user_access_key_id" {
  sensitive   = true
  value       = "${module.kops_ecr_user.access_key_id}"
  description = "The access key ID"
}

output "kops_ecr_user_secret_access_key" {
  sensitive   = true
  value       = "${module.kops_ecr_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}
