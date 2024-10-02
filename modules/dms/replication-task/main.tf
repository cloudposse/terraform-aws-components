module "dms_replication_task" {
  source  = "cloudposse/dms/aws//modules/dms-replication-task"
  version = "0.1.1"

  replication_instance_arn = module.dms_replication_instance.outputs.dms_replication_instance_arn
  source_endpoint_arn      = module.dms_endpoint_source.outputs.dms_endpoint_arn
  target_endpoint_arn      = module.dms_endpoint_target.outputs.dms_endpoint_arn

  start_replication_task = var.start_replication_task
  migration_type         = var.migration_type
  cdc_start_position     = var.cdc_start_position
  cdc_start_time         = var.cdc_start_time

  # https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.html
  replication_task_settings = file("${path.module}/${var.replication_task_settings_file}")

  # https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TableMapping.html
  table_mappings = file("${path.module}/${var.table_mappings_file}")

  context = module.this.context
}
