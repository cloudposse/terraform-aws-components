module "tfstate_backend" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "0.33.0"

  force_destroy                 = var.force_destroy
  prevent_unencrypted_uploads   = var.prevent_unencrypted_uploads
  enable_server_side_encryption = var.enable_server_side_encryption

  context = module.this.context
}
