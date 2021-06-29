# Set the default mode for EBS volumes to be encrypted
resource "aws_ebs_encryption_by_default" "default" {
  enabled = true
}

# https://www.terraform.io/docs/providers/aws/r/iam_account_password_policy.html
# IAM Account Settings provides a CIS-compliant IAM Password Policy out of the box
module "iam_account_settings" {
  source  = "cloudposse/iam-account-settings/aws"
  version = "0.3.1"

  hard_expiry             = true
  minimum_password_length = var.minimum_password_length
  maximum_password_age    = var.maximum_password_age

  context = module.this.context
}
