output "lambda_forwarder_rds_function_arn" {
  description = "Datadog Lambda forwarder RDS Enhanced Monitoring function ARN"
  value       = module.datadog_lambda_forwarder.lambda_forwarder_rds_function_arn
}

output "lambda_forwarder_rds_enhanced_monitoring_function_name" {
  description = "Datadog Lambda forwarder RDS Enhanced Monitoring function name"
  value       = module.datadog_lambda_forwarder.lambda_forwarder_rds_enhanced_monitoring_function_name
}

output "lambda_forwarder_log_function_arn" {
  description = "Datadog Lambda forwarder CloudWatch/S3 function ARN"
  value       = module.datadog_lambda_forwarder.lambda_forwarder_log_function_arn
}

output "lambda_forwarder_log_function_name" {
  description = "Datadog Lambda forwarder CloudWatch/S3 function name"
  value       = module.datadog_lambda_forwarder.lambda_forwarder_log_function_name
}

output "lambda_forwarder_vpc_log_function_arn" {
  description = "Datadog Lambda forwarder VPC Flow Logs function ARN"
  value       = module.datadog_lambda_forwarder.lambda_forwarder_vpc_log_function_arn
}

output "lambda_forwarder_vpc_log_function_name" {
  description = "Datadog Lambda forwarder VPC Flow Logs function name"
  value       = module.datadog_lambda_forwarder.lambda_forwarder_vpc_log_function_name
}
