variable "kops_iam_enabled" {
  type        = "string"
  description = "Set to true to allow the module to create Kubernetes and IAM resources"
  default     = "false"
}

variable "cluster_id" {
  type        = "string"
  description = "A unique-per-cluster identifier to prevent replay attacks. Good choices are a random token or a domain name that will be unique to your cluster"
  default     = "random"
}

variable "kube_config_path" {
  type        = "string"
  default     = "/dev/shm/kubecfg"
  description = "Path to the kube config file"
}

variable "admin_k8s_username" {
  type        = "string"
  description = "Kops admin username to be mapped to `admin_iam_role_arn`"
  default     = "kubernetes-admin"
}

variable "admin_k8s_groups" {
  type        = "list"
  description = "List of Kops groups to be mapped to `admin_iam_role_arn`"
  default     = ["system:masters"]
}

variable "readonly_k8s_username" {
  type        = "string"
  description = "Kops readonly username to be mapped to `readonly_iam_role_arn`"
  default     = "kubernetes-readonly"
}

variable "readonly_k8s_groups" {
  type        = "list"
  description = "List of Kops groups to be mapped to `readonly_iam_role_arn`"
  default     = ["view"]
}

resource "kubernetes_cluster_role_binding" "view" {
  count = "${var.kops_iam_enabled == "true" ? 1 : 0}"

  metadata {
    name = "view-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "Group"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}

variable "aws_root_account_id" {
  type        = "string"
  description = "AWS root account ID"
}

module "kops_admin_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "kops"
  stage      = "${var.stage}"
  attributes = ["admin"]
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "${var.kops_iam_enabled}"
}

module "kops_readonly_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "kops"
  stage      = "${var.stage}"
  attributes = ["readonly"]
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "${var.kops_iam_enabled}"
}

data "aws_iam_policy_document" "readonly" {
  count = "${var.kops_iam_enabled == "true" ? 1 : 0}"

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_root_account_id}:root"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "readonly" {
  count              = "${var.kops_iam_enabled == "true" ? 1 : 0}"
  name               = "${module.kops_readonly_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.readonly.json}"
  description        = "The Kops readonly role for aws-iam-authenticator"

  max_session_duration = "${var.iam_role_max_session_duration}"
}

data "aws_iam_policy_document" "admin" {
  count = "${var.kops_iam_enabled == "true" ? 1 : 0}"

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_root_account_id}:root"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "admin" {
  count              = "${var.kops_iam_enabled == "true" ? 1 : 0}"
  name               = "${module.kops_admin_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.admin.json}"
  description        = "The Kops admin role for aws-iam-authenticator"

  max_session_duration = "${var.iam_role_max_session_duration}"
}

module "iam_authenticator_config" {
  enabled               = "${var.kops_iam_enabled}"
  source                = "git::https://github.com/cloudposse/terraform-aws-kops-iam-authenticator-config.git?ref=tags/0.2.2"
  cluster_id            = "${var.cluster_id}"
  kube_config_path      = "${var.kube_config_path}"
  admin_iam_role_arn    = "${element(concat(aws_iam_role.admin.*.arn, list("")), 0)}"
  admin_k8s_username    = "${var.admin_k8s_username}"
  admin_k8s_groups      = "${var.admin_k8s_groups}"
  readonly_iam_role_arn = "${element(concat(aws_iam_role.readonly.*.arn, list("")), 0)}"
  readonly_k8s_username = "${var.readonly_k8s_username}"
  readonly_k8s_groups   = "${var.readonly_k8s_groups}"
}
