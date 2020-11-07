output "account_alias" {
  value       = aws_iam_account_alias.default.account_alias
  description = "Account alias"
}

output "expire_passwords" {
  value       = aws_iam_account_password_policy.default.expire_passwords
  description = "Indicates whether passwords in the account expire. Returns `true` if `max_password_age` contains a value greater than 0. Returns `false` if it is 0 or not present"
}
