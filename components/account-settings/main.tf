# Set the default mode for EBS volumes to be encrypted
resource "aws_ebs_encryption_by_default" "default" {
  enabled = true
}

# https://www.terraform.io/docs/providers/aws/r/iam_account_alias.html
resource "aws_iam_account_alias" "default" {
  account_alias = format(var.account_alias_template, module.this.environment, module.this.stage)
}

# https://www.terraform.io/docs/providers/aws/r/iam_account_password_policy.html
resource "aws_iam_account_password_policy" "default" {
  allow_users_to_change_password = true
  # hard_expiry = true Prevents IAM users from setting a new password after their password has expired.
  # The IAM user cannot be accessed until an administrator resets the password.
  # Setting it to true provides a lazy way to lock out ex-employees.
  hard_expiry                  = true
  max_password_age             = var.maximum_password_age
  minimum_password_length      = var.minimum_password_length
  password_reuse_prevention    = 5
  require_lowercase_characters = true
  require_uppercase_characters = true
  # Current (2020) guidelines stress longer memorable passwords over
  # complex but hard to remember ones,
  # so requiring numbers and symbols is not recommended
  require_numbers = false
  require_symbols = false
}
