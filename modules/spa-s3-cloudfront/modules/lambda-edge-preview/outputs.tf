output "lambda_function_association" {
  description = "The Lambda@Edge function association configuration to pass to `var.cloudfront_lambda_function_association` in the parent module."
  value       = module.lambda_edge.lambda_function_association
}
