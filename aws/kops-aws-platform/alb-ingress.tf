variable "kops_alb_ingress_enabled" {
  description = "Set to false to prevent the alb ingress from creating IAM resources"
  default     = "false"
}

module "kops_alb_ingress" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-aws-alb-ingress.git?ref=tags/0.2.0"
  namespace    = "${var.namespace}"
  stage        = "${var.stage}"
  name         = "alb-ingress"
  cluster_name = "${var.region}.${var.zone_name}"
  enabled      = "${var.kops_alb_ingress_enabled}"

  iam_role_max_session_duration = "${var.iam_role_max_session_duration}"

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

output "kops_alb_ingress_role_name" {
  value = "${module.kops_alb_ingress.role_name}"
}

output "kops_alb_ingress_role_unique_id" {
  value = "${module.kops_alb_ingress.role_unique_id}"
}

output "kops_alb_ingress_role_arn" {
  value = "${module.kops_alb_ingress.role_arn}"
}

output "kops_alb_ingress_policy_name" {
  value = "${module.kops_alb_ingress.policy_name}"
}

output "kops_alb_ingress_policy_id" {
  value = "${module.kops_alb_ingress.policy_id}"
}

output "kops_alb_ingress_policy_arn" {
  value = "${module.kops_alb_ingress.policy_arn}"
}
