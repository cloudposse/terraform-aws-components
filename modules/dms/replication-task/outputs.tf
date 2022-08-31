output "dms_replication_task_id" {
  value       = module.dms_replication_task.replication_task_id
  description = "DMS replication task ID"
}

output "dms_replication_task_arn" {
  value       = module.dms_replication_task.replication_task_arn
  description = "DMS replication task ARN"
}
