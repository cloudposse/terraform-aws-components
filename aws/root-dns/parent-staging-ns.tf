module "staging" {
  source    = "ns"
  role_arn  = "${data.terraform_remote_state.root.staging_organization_account_access_role}"
  namespace = "${var.namespace}"
  stage     = "staging"
  zone_id   = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "staging_name_servers" {
  value = "${module.staging.name_servers}"
}
