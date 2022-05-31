# Set the default mode for EBS volumes to be encrypted
resource "aws_ebs_encryption_by_default" "default" {
  count   = module.this.enabled ? 1 : 0
  enabled = true
}

# IAM Account Settings provides a CIS-compliant IAM Password Policy out of the box
# It also sets the account alias for the current account.
module "iam_account_settings" {
  source  = "cloudposse/iam-account-settings/aws"
  version = "0.4.0"

  hard_expiry             = true
  minimum_password_length = var.minimum_password_length
  max_password_age        = var.maximum_password_age

  context = module.this.context
}
