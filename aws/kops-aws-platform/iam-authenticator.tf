variable "cluster_id" {
  type        = "string"
  description = "A unique-per-cluster identifier to prevent replay attacks. Good choices are a random token or a domain name that will be unique to your cluster"
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
  default     = ["system:authenticated"]
}

variable "aws_root_account_id" {
  type        = "string"
  description = "AWS root account ID"
}

variable "kops_readonly_role_name" {
  type        = "string"
  default     = "KopsReadOnly"
  description = "IAM role name for the Kubernetes readonly user, used by aws-iam-authenticator"
}

variable "kops_admin_role_name" {
  type        = "string"
  default     = "KopsAdmin"
  description = "IAM role name for the Kubernetes admin user, used by aws-iam-authenticator"
}

data "aws_iam_policy_document" "readonly" {
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
  name               = "${var.kops_readonly_role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.readonly.json}"
  description        = "The Kops readonly role for aws-iam-authenticator"
}

data "aws_iam_policy_document" "admin" {
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
  name               = "${var.kops_admin_role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.admin.json}"
  description        = "The Kops admin role for aws-iam-authenticator"
}

module "iam_authenticator_config" {
  source                = "git::https://github.com/cloudposse/terraform-aws-kops-iam-authenticator-config.git?ref=tags/0.1.1"
  cluster_id            = "${var.cluster_id}"
  kube_config_path      = "${var.kube_config_path}"
  admin_iam_role_arn    = "${aws_iam_role.admin.arn}"
  admin_k8s_username    = "${var.admin_k8s_username}"
  admin_k8s_groups      = "${var.admin_k8s_groups}"
  readonly_iam_role_arn = "${aws_iam_role.readonly.arn}"
  readonly_k8s_username = "${var.readonly_k8s_username}"
  readonly_k8s_groups   = "${var.readonly_k8s_groups}"
}
