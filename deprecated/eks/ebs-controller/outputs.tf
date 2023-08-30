output "ebs_csi_driver_name" {
  description = "The Name of the EBS CSI driver"
  value       = module.ebs_csi_driver_controller.ebs_csi_driver_name
}

output "ebs_csi_driver_controller_role_arn" {
  description = "The Name of the EBS CSI driver controller IAM role ARN"
  value       = module.ebs_csi_driver_controller.ebs_csi_driver_controller_role_arn
}

output "ebs_csi_driver_controller_role_name" {
  description = "The Name of the EBS CSI driver controller IAM role name"
  value       = module.ebs_csi_driver_controller.ebs_csi_driver_controller_role_name
}

output "ebs_csi_driver_controller_role_policy_arn" {
  description = "The Name of the EBS CSI driver controller IAM role policy ARN"
  value       = module.ebs_csi_driver_controller.ebs_csi_driver_controller_role_policy_arn
}

output "ebs_csi_driver_controller_role_policy_name" {
  description = "The Name of the EBS CSI driver controller IAM role policy name"
  value       = module.ebs_csi_driver_controller.ebs_csi_driver_controller_role_policy_name
}
