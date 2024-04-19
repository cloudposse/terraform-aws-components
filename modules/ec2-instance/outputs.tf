output "instance_id" {
  value       = module.ec2_instance[*].id
  description = "Instance ID"
}

output "private_ip" {
  value       = module.ec2_instance[*].private_ip
  description = "Private IP of the instance"
}
