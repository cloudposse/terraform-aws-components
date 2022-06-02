module "s3_bucket" {
  count                         = var.create_bucket ? 1 : 0
  source                        = "cloudposse/s3-bucket/aws"
  version                       = "0.49.0"
  acl                           = "private"
  enabled                       = true
  user_enabled                  = false
  versioning_enabled            = true
  name                          = var.name
  lifecycle_configuration_rules = local.lifecycle_configuration_rules

  context = module.this.context
}

locals {
  lifecycle_configuration_rules = [{
    enabled = true # bool
    id      = "Expire Old and Incomplete Object Versions"

    abort_incomplete_multipart_upload_days = 14 # number

    filter_and = null

    noncurrent_version_expiration = {
      newer_noncurrent_versions = 5  # integer > 0
      noncurrent_days           = 30 # integer >= 0
    }

    # These attributes are required to be present, but deliberately
    # unset because we want to keep current, complete copies of all
    # objects indefinitely at this point - while still expiring
    # former versions and partial uploads within a month.
    expiration                    = {}
    transition                    = [{}]
    noncurrent_version_transition = [{}]
  }]
}

