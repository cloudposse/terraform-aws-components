locals {
  dynamodb_chamber_service = coalesce(var.dynamodb_chamber_service, var.chamber_service, basename(pathexpand(path.module)))
}

resource "aws_ssm_parameter" "dynamodb_table_name" {
  count       = var.chamber_parameters_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name, local.dynamodb_chamber_service, "dynamodb_table_name")
  value       = module.dynamodb.table_name
  description = "DynamoDB table name"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "dynamodb_table_id" {
  count       = var.chamber_parameters_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name, local.dynamodb_chamber_service, "dynamodb_table_id")
  value       = module.dynamodb.table_id
  description = "DynamoDB table ID"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "dynamodb_table_arn" {
  count       = var.chamber_parameters_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name, local.dynamodb_chamber_service, "dynamodb_table_arn")
  value       = module.dynamodb.table_arn
  description = "DynamoDB table ARN"
  type        = "String"
  overwrite   = true
}
