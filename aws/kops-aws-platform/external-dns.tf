module "kops_external_dns" {
  source         = "git::https://github.com/cloudposse/terraform-aws-kops-external-dns.git?ref=tags/0.3.0"
  namespace      = "${var.namespace}"
  stage          = "${var.stage}"
  name           = "external-dns"
  cluster_name   = "${var.region}.${var.zone_name}"
  dns_zone_names = "${var.dns_zone_names}"

  iam_role_max_session_duration = "${var.iam_role_max_session_duration}"

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

output "kops_external_dns_role_name" {
  value = "${module.kops_external_dns.role_name}"
}

output "kops_external_dns_role_unique_id" {
  value = "${module.kops_external_dns.role_unique_id}"
}

output "kops_external_dns_role_arn" {
  value = "${module.kops_external_dns.role_arn}"
}

output "kops_external_dns_policy_name" {
  value = "${module.kops_external_dns.policy_name}"
}

output "kops_external_dns_policy_id" {
  value = "${module.kops_external_dns.policy_id}"
}

output "kops_external_dns_policy_arn" {
  value = "${module.kops_external_dns.policy_arn}"
}
