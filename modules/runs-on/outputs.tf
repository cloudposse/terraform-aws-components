output "name" {
  value       = one(module.cloudformation_stack[*].name)
  description = "Name of the CloudFormation Stack"
}

output "id" {
  value       = one(module.cloudformation_stack[*].id)
  description = "ID of the CloudFormation Stack"
}

output "outputs" {
  value       = one(module.cloudformation_stack[*].outputs)
  description = "Outputs of the CloudFormation Stack"
}

output "vpc_id" {
  value       = local.vpc_id
  description = "ID of the VPC created by RunsOn CloudFormation Stack"
}

output "vpc_cidr" {
  value       = local.vpc_cidr_block
  description = "CIDR of the VPC created by RunsOn CloudFormation Stack"
}

output "nat_gateway_ids" {
  value       = one(data.aws_nat_gateways.ngws[*].ids)
  description = "NAT Gateway IDs"
}

// Required by TGW Component but not created by RunsOn CloudFormation Stack
output "nat_instance_ids" {
  value       = []
  description = "NAT Instance IDs"
}

output "private_subnet_ids" {
  value = local.private_subnet_ids
  #   value       = one(data.aws_subnets.private_subnets[*].ids)
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value = local.public_subnet_ids
  #   value       = one(data.aws_subnets.public_subnets[*].ids)
  description = "Public subnet IDs"
}

output "private_route_table_ids" {
  value       = local.private_route_table_ids
  description = "Private subnet route table IDs"
}
