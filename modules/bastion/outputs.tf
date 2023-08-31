output "autoscaling_group_id" {
  value       = module.bastion_autoscale_group.autoscaling_group_id
  description = "The AutoScaling Group ID"
}

output "iam_instance_profile" {
  value       = join("", aws_iam_instance_profile.default[*].name)
  description = "Name of AWS IAM Instance Profile"
}

output "security_group_id" {
  value       = module.sg.id
  description = "ID on the AWS Security Group associated with the ASG"
}
