output "id" {
  description = "The ID of the User Pool"
  value       = local.enabled ? aws_cognito_user_pool.pool[0].id : null
}

output "arn" {
  description = "The ARN of the User Pool"
  value       = local.enabled ? aws_cognito_user_pool.pool[0].arn : null
}

output "endpoint" {
  description = "The endpoint name of the User Pool. Example format: cognito-idp.REGION.amazonaws.com/xxxx_yyyyy"
  value       = local.enabled ? aws_cognito_user_pool.pool[0].endpoint : null
}

output "creation_date" {
  description = "The date the User Pool was created"
  value       = local.enabled ? aws_cognito_user_pool.pool[0].creation_date : null
}

output "last_modified_date" {
  description = "The date the User Pool was last modified"
  value       = local.enabled ? aws_cognito_user_pool.pool[0].last_modified_date : null
}

#
# aws_cognito_user_pool_domain
#
output "domain_aws_account_id" {
  description = "The AWS account ID for the User Pool domain"
  value       = local.enabled ? join("", aws_cognito_user_pool_domain.domain.*.aws_account_id) : null
}

output "domain_cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution for the domain"
  value       = local.enabled ? join("", aws_cognito_user_pool_domain.domain.*.cloudfront_distribution_arn) : null
}

output "domain_s3_bucket" {
  description = "The S3 bucket where the static files for the domain are stored"
  value       = local.enabled ? join("", aws_cognito_user_pool_domain.domain.*.s3_bucket) : null
}

output "domain_app_version" {
  description = "The app version for the domain"
  value       = local.enabled ? join("", aws_cognito_user_pool_domain.domain.*.version) : null
}

#
# aws_cognito_user_pool_client
#
output "client_ids" {
  description = "The ids of the User Pool clients"
  value       = local.enabled ? aws_cognito_user_pool_client.client.*.id : null
}

output "client_secrets" {
  description = " The client secrets of the User Pool clients"
  value       = local.enabled ? aws_cognito_user_pool_client.client.*.client_secret : null
  sensitive   = true
}

output "client_ids_map" {
  description = "The IDs map of the User Pool clients"
  value       = local.enabled ? { for k, v in aws_cognito_user_pool_client.client : v.name => v.id } : null
}

output "client_secrets_map" {
  description = "The client secrets map of the User Pool clients"
  value       = local.enabled ? { for k, v in aws_cognito_user_pool_client.client : v.name => v.client_secret } : null
  sensitive   = true
}

#
# aws_cognito_resource_servers
#
output "resource_servers_scope_identifiers" {
  description = " A list of all scopes configured in the format identifier/scope_name"
  value       = local.enabled ? aws_cognito_resource_server.resource.*.scope_identifiers : null
}
