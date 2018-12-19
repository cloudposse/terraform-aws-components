module "audit" {
  source    = "ns"
  role_arn  = "${data.terraform_remote_state.root.audit_organization_account_access_role}"
  namespace = "${var.namespace}"
  stage     = "audit"
  zone_id   = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "audit_name_servers" {
  value = "${module.audit.name_servers}"
}
