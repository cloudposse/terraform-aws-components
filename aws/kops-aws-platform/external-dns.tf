module "kops_external_dns" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-external-dns.git?ref=tags/0.1.2"
  namespace    = "${module.identity.namespace}"
  stage        = "${module.identity.stage}"
  name         = "external-dns"
  cluster_name = "${module.identity.aws_region}.${module.identity.zone_name}"

  tags = {
    Cluster = "${module.identity.aws_region}.${module.identity.zone_name}"
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
