variable "efs_enabled" {
  type        = "string"
  description = "Set to true to allow the module to create EFS resources"
  default     = "false"
}

variable "kops_dns_zone_id" {
  type        = "string"
  default     = ""
  description = "DNS Zone ID for kops. EFS DNS entries will be added to this zone. If empyty, zone ID will be retrieved from SSM Parameter store"
}

data "aws_ssm_parameter" "kops_availability_zones" {
  name  = "${format(local.chamber_parameter_format, var.chamber_service_kops, "kops_availability_zones")}"
}

data "aws_ssm_parameter" "kops_zone_id" {
  count = "${var.efs_enabled == "true" && var.kops_dns_zone_id == "" ? 1 : 0}"
  name  = "${format(local.chamber_parameter_format, var.chamber_service_kops, "kops_dns_zone_id")}"
}

locals {
  kops_zone_id = "${coalesce(var.kops_dns_zone_id, join("", data.aws_ssm_parameter.kops_zone_id.*.value))}"
}

module "kops_efs_provisioner" {
  source             = "git::https://github.com/cloudposse/terraform-aws-kops-efs.git?ref=tags/0.4.0"
  enabled            = "${var.efs_enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "efs-provisioner"
  region             = "${var.region}"
  availability_zones = ["${split(",", data.aws_ssm_parameter.kops_availability_zones.value)}"]
  zone_id            = "${local.kops_zone_id}"
  cluster_name       = "${var.region}.${var.zone_name}"

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

resource "aws_ssm_parameter" "kops_efs_provisioner_role_name" {
  count       = "${var.efs_enabled == "true" ? 1 : 0}"
  name        = "${format(local.chamber_parameter_format, var.chamber_service, "kops_efs_provisioner_role_name")}"
  value       = "${module.kops_efs_provisioner.role_name}"
  description = "IAM role name for EFS provisioner"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_efs_file_system_id" {
  count       = "${var.efs_enabled == "true" ? 1 : 0}"
  name        = "${format(local.chamber_parameter_format, var.chamber_service, "kops_efs_file_system_id")}"
  value       = "${module.kops_efs_provisioner.efs_id}"
  description = "ID for shared EFS file system"
  type        = "String"
  overwrite   = "true"
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
