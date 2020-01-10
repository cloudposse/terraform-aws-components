module "dynamodb" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=tags/0.15.0"

  namespace           = var.namespace
  stage               = var.stage
  environment         = var.environment
  name                = var.name
  delimiter           = var.delimiter
  attributes          = var.attributes
  tags                = var.tags
  regex_replace_chars = var.regex_replace_chars

  billing_mode     = var.billing_mode
  stream_view_type = var.stream_view_type

  hash_key                   = var.hash_key
  hash_key_type              = var.hash_key_type
  range_key                  = var.range_key
  range_key_type             = var.range_key_type
  dynamodb_attributes        = var.dynamodb_attributes
  ttl_attribute              = var.ttl_attribute
  global_secondary_index_map = var.global_secondary_index_map
  local_secondary_index_map  = var.local_secondary_index_map

  enable_streams                = var.enable_streams
  enable_encryption             = var.enable_encryption
  enable_point_in_time_recovery = var.enable_point_in_time_recovery

  enable_autoscaler            = var.enable_autoscaler
  autoscale_write_target       = var.autoscale_write_target
  autoscale_read_target        = var.autoscale_read_target
  autoscale_min_read_capacity  = var.autoscale_min_read_capacity
  autoscale_max_read_capacity  = var.autoscale_max_read_capacity
  autoscale_min_write_capacity = var.autoscale_min_write_capacity
  autoscale_max_write_capacity = var.autoscale_max_write_capacity
}

module "dynamodb_backup" {
  source             = "git::https://github.com/cloudposse/terraform-aws-backup.git?ref=tags/0.1.1"
  enabled            = var.enable_backup
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  delimiter          = var.delimiter
  attributes         = var.attributes
  tags               = var.tags
  backup_resources   = [module.dynamodb.table_arn]
  schedule           = var.backup_schedule
  start_window       = var.backup_start_window
  completion_window  = var.backup_completion_window
  cold_storage_after = var.backup_cold_storage_after
  delete_after       = var.backup_delete_after
  kms_key_arn        = var.backup_kms_key_arn
}
