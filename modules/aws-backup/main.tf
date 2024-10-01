module "backup" {
  source  = "cloudposse/backup/aws"
  version = "1.0.0"

  plan_name_suffix = var.plan_name_suffix
  vault_enabled    = var.vault_enabled
  iam_role_enabled = var.iam_role_enabled
  plan_enabled     = var.plan_enabled

  backup_resources = var.backup_resources
  selection_tags   = var.selection_tags

  kms_key_arn = var.kms_key_arn

  rules                           = var.rules
  advanced_backup_setting         = var.advanced_backup_setting
  backup_vault_lock_configuration = var.backup_vault_lock_configuration

  context = module.this.context
}
