module "tfstate_backend" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=tags/0.26.1"
  namespace                     = module.this.namespace
  stage                         = module.this.stage
  environment                   = module.this.environment
  name                          = module.this.name
  delimiter                     = module.this.delimiter
  attributes                    = module.this.attributes
  tags                          = module.this.tags
  region                        = var.region
  force_destroy                 = var.force_destroy
  prevent_unencrypted_uploads   = var.prevent_unencrypted_uploads
  enable_server_side_encryption = var.enable_server_side_encryption
}
