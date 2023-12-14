locals {
  copy_action_enabled            = module.this.enabled && (var.destination_vault_arn != null || (var.destination_vault_component_name != null && var.destination_vault_region != null))
  copy_destination_arn_selection = var.destination_vault_arn != null ? var.destination_vault_arn : try(module.copy_destination_vault[0].outputs.backup_vault_arn, null)
  copy_destination_arn           = local.copy_action_enabled ? local.copy_destination_arn_selection : null
}

module "backup" {
  source  = "cloudposse/backup/aws"
  version = "0.14.0"

  plan_name_suffix = var.plan_name_suffix
  vault_enabled    = var.vault_enabled
  iam_role_enabled = var.iam_role_enabled
  plan_enabled     = var.plan_enabled

  backup_resources = var.backup_resources
  selection_tags   = var.selection_tags

  schedule           = var.schedule
  start_window       = var.start_window
  completion_window  = var.completion_window
  cold_storage_after = var.cold_storage_after
  delete_after       = var.delete_after
  kms_key_arn        = var.kms_key_arn

  # Copy config to new region
  destination_vault_arn          = local.copy_destination_arn
  copy_action_cold_storage_after = var.copy_action_cold_storage_after
  copy_action_delete_after       = var.copy_action_delete_after

  context = module.this.context
}
