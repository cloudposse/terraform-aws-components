output "s3_bucket_arn" {
  value       = module.mwaa_environment.s3_bucket_arn
  description = "ID of S3 bucket."
}

output "arn" {
  value       = module.mwaa_environment.arn
  description = "ARN of MWAA environment."
}

output "logging_configuration" {
  value       = module.mwaa_environment.logging_configuration
  description = "The Logging Configuration of the MWAA Environment"
}

output "security_group_id" {
  description = "ID of the MWAA Security Group(s)"
  value       = module.mwaa_environment.security_group_id
}

output "execution_role_arn" {
  description = "IAM Role ARN for Amazon MWAA Execution Role"
  value       = module.mwaa_environment.execution_role_arn
}

output "created_at" {
  description = "The Created At date of the Amazon MWAA Environment"
  value       = module.mwaa_environment.created_at
}

output "service_role_arn" {
  description = "The Service Role ARN of the Amazon MWAA Environment"
  value       = module.mwaa_environment.service_role_arn
}

output "status" {
  description = "The status of the Amazon MWAA Environment"
  value       = module.mwaa_environment.status
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider for the Amazon MWAA Environment"
  value       = module.mwaa_environment.tags_all
}

output "webserver_url" {
  description = "The webserver URL of the Amazon MWAA Environment"
  value       = module.mwaa_environment.webserver_url
}
