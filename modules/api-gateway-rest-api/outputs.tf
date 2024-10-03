output "id" {
  description = "The ID of the REST API"
  value       = module.this.enabled ? module.api_gateway_rest_api.id : null
}

output "root_resource_id" {
  description = "The resource ID of the REST API's root"
  value       = module.this.enabled ? module.api_gateway_rest_api.root_resource_id : null
}

output "created_date" {
  description = "The date the REST API was created"
  value       = module.this.enabled ? module.api_gateway_rest_api.created_date : null
}

output "execution_arn" {
  description = <<EOF
    The execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda
    function, e.g., arn:aws:execute-api:eu-west-2:123456789012:z4675bid1j, which can be concatenated with allowed stage,
    method and resource path.The ARN of the Lambda function that will be executed.
    EOF
  value       = module.this.enabled ? module.api_gateway_rest_api.execution_arn : null
}

output "arn" {
  description = "The ARN of the REST API"
  value       = module.this.enabled ? module.api_gateway_rest_api.arn : null
}

output "invoke_url" {
  description = "The URL to invoke the REST API"
  value       = module.this.enabled ? module.api_gateway_rest_api.invoke_url : null
}
