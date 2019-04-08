module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.1.1"
  dns_zone     = "${var.cluster_name}"
  masters_name = "${var.masters_name}"
  nodes_name   = "${var.nodes_name}"
}

locals {
  kops_roles = [
    "${module.kops_metadata.masters_role_arn}",
    "${module.kops_metadata.nodes_role_arn}",
  ]
}

data "aws_iam_policy" "ec2_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "athena_full" {
  arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

module "iam_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.2.0"
  namespace = "${var.namespace}"
  policy_description = "Policy required for Kubecost (AmazonEC2ReadOnlyAccess read and AmazonAthenaFullAccess)"
  stage = "${var.stage}"
  name = "kubecost"
  principals_arns = ["${module.kops_metadata.masters_role_arn}"]
  role_description = "Role for policy required for Kubecost (AmazonEC2ReadOnlyAccess read and AmazonAthenaFullAccess)"
  policy_documents = ["${data.aws_iam_policy.ec2_read_only.policy}", "${data.aws_iam_policy.athena_full.policy}"]
}
