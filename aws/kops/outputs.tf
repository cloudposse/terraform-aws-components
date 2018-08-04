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

output "ssh_key_name" {
  value = "${module.ssh_key_pair.key_name}"
}

output "ssh_public_key" {
  value = "${module.ssh_key_pair.public_key}"
}
