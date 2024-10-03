output "endpoint_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Serverless Endpoint Access."
  value       = join("", aws_redshiftserverless_endpoint_access.default[*].arn)
}

output "endpoint_id" {
  description = "The Redshift Endpoint Access Name."
  value       = join("", aws_redshiftserverless_endpoint_access.default[*].id)
}

output "endpoint_address" {
  description = "The DNS address of the VPC endpoint."
  value       = join("", aws_redshiftserverless_endpoint_access.default[*].address)
}

output "endpoint_port" {
  description = "The port that Amazon Redshift Serverless listens on."
  value       = join("", aws_redshiftserverless_endpoint_access.default[*].port)
}

output "endpoint_vpc_endpoint" {
  description = "The VPC endpoint or the Redshift Serverless workgroup. See VPC Endpoint below."
  value       = aws_redshiftserverless_endpoint_access.default[0].vpc_endpoint
  #  value       = join("", aws_redshiftserverless_endpoint_access.default[*].vpc_endpoint)
}

output "endpoint_name" {
  description = "Endpoint Name."
  value       = join("", aws_redshiftserverless_endpoint_access.default[*].endpoint_name)
}

output "endpoint_subnet_ids" {
  description = "Subnets used in redshift serverless endpoint."
  value       = aws_redshiftserverless_endpoint_access.default[0].subnet_ids
}

output "namespace_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Serverless Namespace."
  value       = join("", aws_redshiftserverless_namespace.default[*].arn)
}

output "namespace_id" {
  description = "The Redshift Namespace Name."
  value       = join("", aws_redshiftserverless_namespace.default[*].id)
}

output "namespace_namespace_id" {
  description = "The Redshift Namespace ID."
  value       = join("", aws_redshiftserverless_namespace.default[*].namespace_id)
}

output "workgroup_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Serverless Workgroup."
  value       = join("", aws_redshiftserverless_workgroup.default[*].arn)
}

output "workgroup_id" {
  description = "The Redshift Workgroup Name."
  value       = join("", aws_redshiftserverless_workgroup.default[*].id)
}

output "workgroup_workgroup_id" {
  description = "The Redshift Workgroup ID."
  value       = join("", aws_redshiftserverless_workgroup.default[*].workgroup_id)
}

output "workgroup_endpoint" {
  description = "The Redshift Serverless Endpoint."
  value       = aws_redshiftserverless_workgroup.default[0].endpoint
}
