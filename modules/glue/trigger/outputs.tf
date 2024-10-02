output "trigger_id" {
  description = "Glue trigger ID"
  value       = module.glue_trigger.id
}

output "trigger_name" {
  description = "Glue trigger name"
  value       = module.glue_trigger.name
}

output "trigger_arn" {
  description = "Glue trigger ARN"
  value       = module.glue_trigger.arn
}
