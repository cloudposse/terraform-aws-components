module "tfstate_backend" {
  source = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=tags/0.28.0"

  force_destroy                 = var.force_destroy
  prevent_unencrypted_uploads   = var.prevent_unencrypted_uploads
  enable_server_side_encryption = var.enable_server_side_encryption

  context = module.this.context
}
