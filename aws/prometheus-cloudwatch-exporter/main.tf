module "label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  namespace = var.namespace
  stage     = var.stage
  name      = var.name
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.2.0"
  cluster_name = var.kops_cluster_name
}

resource "aws_iam_role" "default" {
  name        = module.label.id
  description = "Role that can be assumed by prometheus-cloudwatch-exporter"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
    sid = "ReadMetricStatistics"

    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}


locals {
  chamber_service = coalesce(var.chamber_service, basename(pathexpand(path.module)))
}


resource "kubernetes_namespace" "default" {
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

resource "aws_ssm_parameter" "prometheus_cloudwatch_exporter_iam_role" {
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "prometheus_cloudwatch_exporter_iam_role")
  value       = aws_iam_role.default.name
  description = "IAM role name for prometheus-cloudwatch-exporter role"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "prometheus_cloudwatch_exporter_iam_namespace" {
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "prometheus_cloudwatch_exporter_iam_namespace")
  value       = var.cloudwatch_namespace
  description = "Kubernetes namespace for prometheus-cloudwatch-exporter"
  type        = "String"
  overwrite   = "true"
}

output "prometheus_cloudwatch_exporter_namespace" {
  value = var.cloudwatch_namespace
}

output "prometheus_cloudwatch_exporter_iam_role_name" {
  value = aws_iam_role.default.name
}

output "prometheus_cloudwatch_exporter_iam_role_unique_id" {
  value = aws_iam_role.default.unique_id
}

output "prometheus_cloudwatch_exporter_iam_role_arn" {
  value = aws_iam_role.default.arn
}
