output "parent_zone_id" {
  value = "${module.kops_state_backend.parent_zone_id}"
}

output "parent_zone_name" {
  value = "${module.kops_state_backend.parent_zone_name}"
}

output "zone_id" {
  value = "${module.kops_state_backend.zone_id}"
}

output "zone_name" {
  value = "${module.kops_state_backend.zone_name}"
}

output "bucket_name" {
  value = "${module.kops_state_backend.bucket_name}"
}

output "bucket_region" {
  value = "${module.kops_state_backend.bucket_region}"
}

output "bucket_domain_name" {
  value = "${module.kops_state_backend.bucket_domain_name}"
}

output "bucket_id" {
  value = "${module.kops_state_backend.bucket_id}"
}

output "bucket_arn" {
  value = "${module.kops_state_backend.bucket_arn}"
}

output "ssh_public_key" {
  value = "${module.ssh_key_pair.public_key}"
}

output "availability_zones" {
  value = "${join(",", local.availability_zones)}"
}

output "kops_shared_vpc_id" {
  value = "${join("", aws_ssm_parameter.kops_shared_vpc_id.*.value)}"
}

output "kops_shared_nat_gateways" {
  value = "${join("", aws_ssm_parameter.kops_shared_nat_gateways.*.value)}"
}

output "kops_shared_utility_subnet_ids" {
  value = "${join("", aws_ssm_parameter.kops_shared_utility_subnet_ids.*.value)}"
}

output "kops_shared_private_subnet_ids" {
  value = "${join("", aws_ssm_parameter.kops_shared_private_subnet_ids.*.value)}"
}

output "private_subnets" {
  value = "${local.private_subnet_cidrs}"
}

output "utility_subnets" {
  value = "${local.utility_subnet_cidrs}"
}
