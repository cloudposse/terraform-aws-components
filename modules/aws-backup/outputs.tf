output "backup_vault_id" {
  value       = module.backup.backup_vault_id
  description = "Backup Vault ID"
}

output "backup_vault_arn" {
  value       = module.backup.backup_vault_arn
  description = "Backup Vault ARN"
}

output "backup_plan_arn" {
  value       = module.backup.backup_plan_arn
  description = "Backup Plan ARN"
}

output "backup_plan_version" {
  value       = module.backup.backup_plan_version
  description = "Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan"
}

output "backup_selection_id" {
  value       = module.backup.backup_selection_id
  description = "Backup Selection ID"
}
