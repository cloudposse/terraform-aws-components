output "workflow_id" {
  description = "Glue workflow ID"
  value       = module.glue_workflow.id
}

output "workflow_name" {
  description = "Glue workflow name"
  value       = module.glue_workflow.name
}

output "workflow_arn" {
  description = "Glue workflow ARN"
  value       = module.glue_workflow.arn
}
