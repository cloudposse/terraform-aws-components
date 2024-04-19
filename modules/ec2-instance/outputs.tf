output "instance_id" {
  value       = module.ec2-instance[*].id
  description = "Instance ID"
}

output "private_ip" {
  value       = module.ec2-instance[*].private_ip
  description = "Private IP of the instance"
}
