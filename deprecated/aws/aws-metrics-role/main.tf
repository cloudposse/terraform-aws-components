module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["role"]
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.2.0"
  cluster_name = var.kops_cluster_name
}

locals {
  # TODO search for kiam-specific role
  kiam_role = module.kops_metadata.masters_role_arn
  role_arns = {
    kiam    = [local.kiam_role]
    masters = [module.kops_metadata.masters_role_arn]
    nodes   = [module.kops_metadata.nodes_role_arn]
    both    = [module.kops_metadata.masters_role_arn, module.kops_metadata.nodes_role_arn]
  }
}

resource "aws_iam_role" "default" {
  name        = module.label.id
  description = "Role that has access to AWS metrics"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  max_session_duration = var.max_session_duration
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [module.kops_metadata.masters_role_arn]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.default.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "default" {
  name        = "${module.label.id}"
  description = "Grant permissions for external-dns"
  policy      = "${data.aws_iam_policy_document.default.json}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "ReadMetricsAndTags"

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "tag:GetResources",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}


locals {
  chamber_service = coalesce(var.chamber_service, basename(pathexpand(path.module)))
}


resource "kubernetes_namespace" "default" {
  count = length(var.cloudwatch_namespace) > 0 ? 1 : 0

  metadata {
    annotations = {
      "iam.amazonaws.com/permitted" = aws_iam_role.default.name
    }

    labels = {
      name = var.cloudwatch_namespace
    }

    name = var.cloudwatch_namespace
  }
}

resource "aws_ssm_parameter" "aws_metrics_iam_role" {
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "aws_metrics_iam_role")
  value       = aws_iam_role.default.name
  description = "IAM role name for AWS metrics access"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aws_metrics_iam_namespace" {
  count       = length(var.cloudwatch_namespace) > 0 ? 1 : 0
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "aws_metrics_iam_namespace")
  value       = var.cloudwatch_namespace
  description = "Kubernetes namespace for AWS metrics accessors"
  type        = "String"
  overwrite   = "true"
}

output "aws_metrics_namespace" {
  value = length(var.cloudwatch_namespace) > 0 ? var.cloudwatch_namespace : "<not managed>"
}

output "aws_metrics_iam_role_name" {
  value = aws_iam_role.default.name
}

output "aws_metrics_iam_role_unique_id" {
  value = aws_iam_role.default.unique_id
}

output "aws_metrics_iam_role_arn" {
  value = aws_iam_role.default.arn
}
