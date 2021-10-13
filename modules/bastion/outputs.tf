output "instance_id" {
  value       = module.ec2_bastion.instance_id
  description = "Instance ID"
}

output "role" {
  value       = module.ec2_bastion.role
  description = "Name of AWS IAM Role associated with the instance"
}

output "private_ip" {
  value       = module.ec2_bastion.private_ip
  description = "Private IP of the instance"
}

output "public_ip" {
  value       = module.ec2_bastion.public_ip
  description = "Public IP of the instance (or EIP)"
}

output "bastion_fqdn" {
  value       = module.ec2_bastion.hostname
  description = "Bastion server custom hostname FQDN"
}

output "security_group_ids" {
  value       = module.ec2_bastion.security_group_ids
  description = "IDs on the AWS Security Groups associated with the instance"
}
