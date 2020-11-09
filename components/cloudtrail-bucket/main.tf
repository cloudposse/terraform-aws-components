module "cloudtrail_s3_bucket" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-s3-bucket.git?ref=tags/0.12.0"

  expiration_days                    = var.expiration_days
  force_destroy                      = false
  glacier_transition_days            = var.glacier_transition_days
  lifecycle_rule_enabled             = true
  noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
  noncurrent_version_transition_days = var.noncurrent_version_transition_days
  sse_algorithm                      = "AES256"
  standard_transition_days           = var.standard_transition_days
  versioning_enabled                 = true

  context = module.this.context
}
