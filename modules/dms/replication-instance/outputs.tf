output "dms_replication_instance_id" {
  value       = module.dms_replication_instance.replication_instance_id
  description = "DMS replication instance ID"
}

output "dms_replication_instance_arn" {
  value       = module.dms_replication_instance.replication_instance_arn
  description = "DMS replication instance ARN"
}
