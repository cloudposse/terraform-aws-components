module "dev" {
  source = "ns"
  role_arn = "${data.terraform_remote_state.root.dev_organization_account_access_role}"
  namespace = "${var.namespace}"
  stage = "dev"
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "dev_name_servers" {
  value = "${module.dev.name_servers}"
}
