output "instance_id" {
  value       = module.ec2_zscaler.*.id
  description = "Instance ID"
}

output "private_ip" {
  value       = module.ec2_zscaler.*.private_ip
  description = "Private IP of the instance"
}
