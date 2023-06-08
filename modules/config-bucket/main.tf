module "config_bucket" {
  source  = "cloudposse/config-storage/aws"
  version = "0.8.1"

  expiration_days                    = var.expiration_days
  force_destroy                      = false
  glacier_transition_days            = var.glacier_transition_days
  lifecycle_rule_enabled             = var.lifecycle_rule_enabled
  noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
  noncurrent_version_transition_days = var.noncurrent_version_transition_days
  sse_algorithm                      = "AES256"
  standard_transition_days           = var.standard_transition_days
  access_log_bucket_name             = var.access_log_bucket_name

  context = module.this.context
}
