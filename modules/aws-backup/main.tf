module "backup" {
  source  = "cloudposse/backup/aws"
  version = "0.8.1"

  context = module.this.context

  plan_name_suffix = var.plan_name_suffix
  vault_enabled    = var.vault_enabled
  iam_role_enabled = var.iam_role_enabled
  plan_enabled     = var.plan_enabled

  backup_resources = var.backup_resources
  selection_tags   = var.selection_tags

  schedule             = var.schedule
  start_window         = var.start_window
  completion_window    = var.completion_window
  cold_storage_after   = var.cold_storage_after
  delete_after         = var.delete_after
  kms_key_arn          = var.kms_key_arn
  target_iam_role_name = var.target_iam_role_name

  # Copy config to new region
  destination_vault_arn          = var.destination_vault_arn
  copy_action_cold_storage_after = var.copy_action_cold_storage_after
  copy_action_delete_after       = var.copy_action_delete_after

  target_vault_name = var.target_vault_name
}

