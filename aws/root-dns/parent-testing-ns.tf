module "testing" {
  source = "ns"
  role_arn = "${data.terraform_remote_state.root.testing_organization_account_access_role}"
  namespace = "${var.namespace}"
  stage = "testing"
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "testing_name_servers" {
  value = "${module.testing.name_servers}"
}
