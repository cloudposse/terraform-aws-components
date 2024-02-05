output "job_id" {
  description = "Glue job ID"
  value       = module.glue_job.id
}

output "job_name" {
  description = "Glue job name"
  value       = module.glue_job.name
}

output "job_arn" {
  description = "Glue job ARN"
  value       = module.glue_job.arn
}
