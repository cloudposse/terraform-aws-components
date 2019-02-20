data "terraform_remote_state" "kops" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "kops/terraform.tfstate"
  }
}

module "kops_efs_provisioner" {
  source             = "git::https://github.com/cloudposse/terraform-aws-kops-efs.git?ref=tags/0.2.0"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "efs-provisioner"
  region             = "${var.region}"
  availability_zones = ["${data.terraform_remote_state.kops.availability_zones}"]
  zone_id            = "${data.terraform_remote_state.kops.zone_id}"
  cluster_name       = "${var.region}.${var.zone_name}"

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

output "kops_efs_provisioner_role_name" {
  value = "${module.kops_efs_provisioner.role_name}"
}

output "kops_efs_provisioner_role_unique_id" {
  value = "${module.kops_efs_provisioner.role_unique_id}"
}

output "kops_efs_provisioner_role_arn" {
  value = "${module.kops_efs_provisioner.role_arn}"
}

output "efs_arn" {
  value       = "${module.kops_efs_provisioner.efs_arn}"
  description = "EFS ARN"
}

output "efs_id" {
  value       = "${module.kops_efs_provisioner.efs_id}"
  description = "EFS ID"
}

output "efs_host" {
  value       = "${module.kops_efs_provisioner.efs_host}"
  description = "EFS host"
}

output "efs_dns_name" {
  value       = "${module.kops_efs_provisioner.efs_dns_name}"
  description = "EFS DNS name"
}

output "efs_mount_target_dns_names" {
  value       = "${module.kops_efs_provisioner.efs_mount_target_dns_names}"
  description = "EFS mount target DNS name"
}

output "efs_mount_target_ids" {
  value       = "${module.kops_efs_provisioner.efs_mount_target_ids}"
  description = "EFS mount target IDs"
}

output "efs_mount_target_ips" {
  value       = "${module.kops_efs_provisioner.efs_mount_target_ips}"
  description = "EFS mount target IPs"
}

output "efs_network_interface_ids" {
  value       = "${module.kops_efs_provisioner.efs_network_interface_ids}"
  description = "EFS network interface IDs"
}
