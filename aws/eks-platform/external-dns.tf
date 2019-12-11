# https://github.com/kubernetes-sigs/external-dns
# https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
# https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
# https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
# https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html


variable "dns_zone_names" {
  type        = list(string)
  description = "Names of DNS zones for `external-dns` to manage"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("external-dns")))
  tags       = var.tags
}

resource "aws_iam_role" "default" {
  name        = module.label.id
  description = "Role that can be assumed by external-dns"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "default" {
  name        = module.label.id
  description = "Grant permissions for external-dns"
  policy      = data.aws_iam_policy_document.default.json
}

data "aws_route53_zone" "default" {
  count        = length(var.dns_zone_names)
  name         = "${element(var.dns_zone_names, count.index)}."
  private_zone = false
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "GrantModifyAccessToDomains"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    effect = "Allow"

    resources = [
      formatlist("arn:aws:route53:::hostedzone/%s", data.aws_route53_zone.default.*.zone_id),
    ]
  }

  statement {
    sid = "GrantListAccessToDomains"

    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

output "external_dns_role_name" {
  value       = aws_iam_role.default.name
  description = "external-dns IAM role name"
}

output "external_dns_role_unique_id" {
  value       = aws_iam_role.default.unique_id
  description = "external-dns IAM role unique ID"
}

output "external_dns_role_arn" {
  value       = aws_iam_role.default.arn
  description = "external-dns IAM role ARN"
}

output "external_dns_policy_name" {
  value       = aws_iam_policy.default.name
  description = "external-dns IAM policy name"
}

output "external_dns_policy_id" {
  value       = aws_iam_policy.default.id
  description = "external-dns IAM policy ID"
}

output "external_dns_policy_arn" {
  value       = aws_iam_policy.default.arn
  description = "external-dns IAM policy ARN"
}
