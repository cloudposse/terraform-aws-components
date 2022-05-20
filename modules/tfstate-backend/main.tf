locals {
  enabled = module.this.enabled
}

module "tfstate_backend" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "0.38.1"

  force_destroy                 = var.force_destroy
  prevent_unencrypted_uploads   = var.prevent_unencrypted_uploads
  enable_server_side_encryption = var.enable_server_side_encryption
  enable_point_in_time_recovery = var.enable_point_in_time_recovery

  context = module.this.context
}
