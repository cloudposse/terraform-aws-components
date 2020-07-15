output "parameter_store_prefix" {
  value = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "")}"
}

output "vpc_id" {
  description = "AWS ID of the VPC created"
  value       = "${aws_ssm_parameter.vpc_id.value}"
}

output "igw_id" {
  description = "AWS ID of Internet Gateway for the VPC"
  value       = "${aws_ssm_parameter.igw_id.value}"
}

output "nat_gateways" {
  description = "Comma-separated string list of AWS IDs of NAT Gateways for the VPC"
  value       = "${join("", aws_ssm_parameter.nat_gateways.*.value)}"
}

output "cidr_block" {
  description = "CIDR block of the VPC"
  value       = "${aws_ssm_parameter.cidr_block.value}"
}

output "availability_zones" {
  description = "Comma-separated string list of avaialbility zones where subnets have been created"
  value       = "${aws_ssm_parameter.availability_zones.value}"
}

output "public_subnet_cidrs" {
  description = "Comma-separated string list of CIDR blocks of public VPC subnets"
  value       = "${aws_ssm_parameter.public_subnet_cidrs.value}"
}

output "public_subnet_ids" {
  description = "Comma-separated string list of AWS IDs of public VPC subnets"
  value       = "${aws_ssm_parameter.public_subnet_ids.value}"
}

output "private_subnet_cidrs" {
  description = "Comma-separated string list of CIDR blocks of private VPC subnets"
  value       = "${aws_ssm_parameter.private_subnet_cidrs.value}"
}

output "private_subnet_ids" {
  description = "Comma-separated string list of AWS IDs of private VPC subnets"
  value       = "${aws_ssm_parameter.private_subnet_ids.value}"
}
