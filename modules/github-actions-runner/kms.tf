resource "aws_kms_key" "github_action_runner" {
  count = local.enabled ? 1 : 0

  description             = "Github Action Runners key used for decryption - ${module.github_action_controller_label.id}"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = module.github_action_controller_label.tags
}

resource "aws_kms_alias" "github_action_runner" {
  count = local.enabled ? 1 : 0

  name          = format("alias/%v", module.github_action_controller_label.id)
  target_key_id = aws_kms_key.github_action_runner[0].key_id
}
