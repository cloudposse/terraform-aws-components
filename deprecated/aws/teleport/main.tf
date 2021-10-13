terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "teleport_backend" {
  source                   = "git::https://github.com/cloudposse/terraform-aws-teleport-storage.git?ref=tags/0.4.0"
  namespace                = "${var.namespace}"
  stage                    = "${var.stage}"
  name                     = "${var.name}"
  attributes               = []
  tags                     = "${var.tags}"
  prefix                   = "${var.s3_prefix}"
  standard_transition_days = "${var.s3_standard_transition_days}"
  glacier_transition_days  = "${var.s3_glacier_transition_days}"
  expiration_days          = "${var.s3_expiration_days}"

  iam_role_max_session_duration = "${var.iam_role_max_session_duration}"

  # Autoscale min_read and min_write capacity will set the provisioned capacity for both cluster state and audit events
  autoscale_min_read_capacity  = "${var.autoscale_min_read_capacity}"
  autoscale_min_write_capacity = "${var.autoscale_min_write_capacity}"

  # Currently the autoscalers for the cluster state and the audit events share the same settings
  autoscale_read_target        = "${var.autoscale_read_target}"
  autoscale_write_target       = "${var.autoscale_write_target}"
  autoscale_max_read_capacity  = "${var.autoscale_max_read_capacity}"
  autoscale_max_write_capacity = "${var.autoscale_max_write_capacity}"
}

module "teleport_role_name" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = ["auth"]
  tags       = "${var.tags}"
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.1.0"
  cluster_name = "${var.cluster_name}"
}

locals {
  chamber_service = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"

  kops_arns = {
    masters = ["${module.kops_metadata.masters_role_arn}"]
    nodes   = ["${module.kops_metadata.nodes_role_arn}"]
    both    = ["${module.kops_metadata.masters_role_arn}", "${module.kops_metadata.nodes_role_arn}"]
    any     = ["*"]
  }
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
      type        = "AWS"
      identifiers = ["${local.kops_arns[var.permitted_nodes]}"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "teleport" {
  name                 = "${module.teleport_role_name.id}"
  assume_role_policy   = "${data.aws_iam_policy_document.assume_role.json}"
  max_session_duration = "${var.iam_role_max_session_duration}"
  description          = "The Teleport role to access teleport backend"
}

data "aws_iam_policy_document" "teleport" {
  // Teleport can use LetsEncrypt to get TLS certificates. For this  // it needs additional permissions which are not included here.

  // Teleport can use SSM to publish "join tokens" and retreive the enterprise  // license, but that is not fully documented, so permissions to access SSM  // are not included at this time.

  // S3 permissions are needed to save and replay SSH sessions
  statement {
    sid       = "ListTeleportSessionData"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:ListBucketVersions"]
    resources = ["arn:aws:s3:::${module.teleport_backend.s3_bucket_id}"]
  }

  statement {
    sid    = "GetTeleportSessionData"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetObject",
    ]

    resources = ["arn:aws:s3:::${module.teleport_backend.s3_bucket_id}/*"]
  }

  // DynamoDB permissions are needed to save configuration and event data
  statement {
    sid     = "ReadWriteTeleportEventAndConfigData"
    effect  = "Allow"
    actions = ["dynamodb:*"]

    resources = [
      "${module.teleport_backend.dynamodb_audit_table_arn}",
      "${module.teleport_backend.dynamodb_audit_table_arn}/index/*",
      "${module.teleport_backend.dynamodb_state_table_arn}",
      "${module.teleport_backend.dynamodb_state_table_arn}/index/*",
      "${module.teleport_backend.dynamodb_state_table_arn}/stream/*",
    ]
  }
}

resource "aws_iam_policy" "teleport" {
  name        = "${module.teleport_role_name.id}"
  description = "Grant permissions for teleport"
  policy      = "${data.aws_iam_policy_document.teleport.json}"
}

resource "aws_iam_role_policy_attachment" "teleport" {
  role       = "${aws_iam_role.teleport.name}"
  policy_arn = "${aws_iam_policy.teleport.arn}"
}

resource "aws_ssm_parameter" "teleport_audit_sessions_uri" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_audit_sessions_uri")}"
  value       = "s3://${module.teleport_backend.s3_bucket_id}"
  description = "Teleport session logs storage URI"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "teleport_audit_events_uri" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_audit_events_uri")}"
  value       = "dynamodb://${module.teleport_backend.dynamodb_audit_table_id}"
  description = "Teleport audite events storage URI"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "teleport_cluster_state_dynamodb_table" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_cluster_state_dynamodb_table")}"
  value       = "${module.teleport_backend.dynamodb_state_table_id}"
  description = "Teleport cluster state storage dynamodb table"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "teleport_auth_iam_role" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_auth_iam_role")}"
  value       = "${aws_iam_role.teleport.name}"
  description = "Teleport auth IAM role"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "teleport_kubernetes_namespace" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_kubernetes_namespace")}"
  value       = "${var.kubernetes_namespace}"
  description = "Teleport auth IAM role"
  type        = "String"
  overwrite   = "true"
}

locals {
  token_names = ["teleport_auth_token", "teleport_node_token", "teleport_proxy_token"]
}

resource "random_string" "tokens" {
  count   = "${length(local.token_names)}"
  length  = 32
  special = false

  keepers {
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_ssm_parameter" "teleport_tokens" {
  count       = "${length(local.token_names)}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "${element(local.token_names, count.index)}")}"
  value       = "${element(random_string.tokens.*.result, count.index)}"
  description = "Teleport join token: ${element(local.token_names, count.index)}"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "teleport_proxy_domain_name" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_proxy_domain_name")}"
  value       = "${var.teleport_proxy_domain_name}"
  description = "Teleport Proxy domain name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "teleport_version" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "teleport_version")}"
  value       = "${var.teleport_version}"
  description = "Teleport version to install"
  type        = "String"
  overwrite   = "true"
}

resource "kubernetes_namespace" "default" {
  metadata {
    annotations = {
      "iam.amazonaws.com/permitted" = "${aws_iam_role.teleport.name}"
    }

    labels = {
      name = "${var.kubernetes_namespace}"
    }

    name = "${var.kubernetes_namespace}"
  }
}
