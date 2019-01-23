module "kops_efs_provisioner" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-efs.git?ref=tags/0.1.0"
  namespace    = "${var.namespace}"
  stage        = "${var.stage}"
  name         = "efs-provisioner"
  cluster_name = "${var.region}.${var.zone_name}"

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
