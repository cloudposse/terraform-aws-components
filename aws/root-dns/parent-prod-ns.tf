module "prod" {
  source    = "ns"
  role_arn  = "${data.terraform_remote_state.root.prod_organization_account_access_role}"
  namespace = "${var.namespace}"
  stage     = "prod"
  zone_id   = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "prod_name_servers" {
  value = "${module.prod.name_servers}"
}
