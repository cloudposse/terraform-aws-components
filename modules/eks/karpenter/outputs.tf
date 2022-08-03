output "metadata" {
  value       = module.karpenter.metadata
  description = "Block status of the deployed release"
}

output "instance_profile" {
  value       = aws_iam_instance_profile.default
  description = "Provisioned EC2 Instance Profile for nodes launched by Karpenter"
}
