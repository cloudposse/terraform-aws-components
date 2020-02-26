data "aws_iam_policy_document" "autoscaler" {
  statement {
    sid = "AutoScaler"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

module "autoscaler_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"

  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "kubernetes"
  attributes         = ["autoscaler", "role"]
  role_description   = "Role for Cluster Auto-Scaler"
  policy_description = "Permit auto-scaling operations on auto-scaling groups"

  max_session_duration = "${var.iam_role_max_session_duration}"

  principals = {
    AWS = ["${module.kops_metadata_iam.masters_role_arn}"]
  }

  policy_documents = ["${data.aws_iam_policy_document.autoscaler.json}"]
}

resource "aws_ssm_parameter" "kops_autoscaler_iam_role_name" {
  name        = "${format(local.chamber_parameter_format, var.chamber_service, "kubernetes_autoscaler_iam_role_name")}"
  value       = "${module.autoscaler_role.name}"
  description = "IAM role name for cluster autoscaler"
  type        = "String"
  overwrite   = "true"
}

output "autoscaler_role_name" {
  value       = "${module.autoscaler_role.name}"
  description = "The name of the IAM role created"
}

output "autoscaler_role_id" {
  value       = "${module.autoscaler_role.id}"
  description = "The stable and unique string identifying the role"
}

output "autoscaler_role_arn" {
  value       = "${module.autoscaler_role.arn}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}
