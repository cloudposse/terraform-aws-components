output "table_name" {
  value       = module.dynamodb.table_name
  description = "DynamoDB table name"
}

output "table_id" {
  value       = module.dynamodb.table_id
  description = "DynamoDB table ID"
}

output "table_arn" {
  value       = module.dynamodb.table_arn
  description = "DynamoDB table ARN"
}

output "global_secondary_index_names" {
  value       = module.dynamodb.global_secondary_index_names
  description = "DynamoDB global secondary index names"
}

output "table_stream_arn" {
  value       = module.dynamodb.table_stream_arn
  description = "DynamoDB table stream ARN"
}

output "table_stream_label" {
  value       = module.dynamodb.table_stream_label
  description = "DynamoDB table stream label"
}
