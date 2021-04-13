# Set the default mode for EBS volumes to be encrypted
resource "aws_ebs_encryption_by_default" "default" {
  enabled = true
}

# https://www.terraform.io/docs/providers/aws/r/iam_account_alias.html
resource "aws_iam_account_alias" "default" {
  account_alias = format(var.account_alias_template, module.this.namespace, module.this.environment, module.this.stage)
}

# https://www.terraform.io/docs/providers/aws/r/iam_account_password_policy.html
# IAM Account Settings provides a CIS-compliant IAM Password Policy out of the box
module "iam_account_settings" {
  source  = "cloudposse/iam-account-settings/aws"
  version = "0.2.0"

  hard_expiry = true
}
