module "athena" {
  source  = "cloudposse/athena/aws"
  version = "0.1.1"

  create_s3_bucket               = var.create_s3_bucket
  athena_s3_bucket_id            = var.athena_s3_bucket_id
  create_kms_key                 = var.create_kms_key
  athena_kms_key                 = var.athena_kms_key
  athena_kms_key_deletion_window = var.athena_kms_key_deletion_window

  workgroup_description              = var.workgroup_description
  bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query
  enforce_workgroup_configuration    = var.enforce_workgroup_configuration
  publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
  workgroup_encryption_option        = var.workgroup_encryption_option
  s3_output_path                     = var.s3_output_path
  workgroup_state                    = var.workgroup_state
  workgroup_force_destroy            = var.workgroup_force_destroy

  databases     = var.databases
  data_catalogs = var.data_catalogs
  named_queries = var.named_queries

  context = module.this.context
}
