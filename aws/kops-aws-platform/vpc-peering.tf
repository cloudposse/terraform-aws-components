# Lookup the backing services VPC
data "aws_vpc" "backing_services_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${module.identity.namespace}-${module.identity.stage}-backing-services"]
  }
}

module "kops_vpc_peering" {
  source                  = "git::https://github.com/cloudposse/terraform-aws-kops-vpc-peering.git?ref=tags/0.1.2"
  namespace               = "${module.identity.namespace}"
  stage                   = "${module.identity.stage}"
  name                    = "kops-peering"
  backing_services_vpc_id = "${data.aws_vpc.backing_services_vpc.id}"
  dns_zone                = "${module.identity.aws_region}.${module.identity.zone_name}"
}

output "kops_vpc_peering_connection_id" {
  value = "${module.kops_vpc_peering.connection_id}"
}

output "kops_vpc_peering_accept_status" {
  value = "${module.kops_vpc_peering.accept_status}"
}
