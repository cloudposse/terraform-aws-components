output "account_alias" {
  value = "${module.account_settings.account_alias}"
}

output "minimum_password_length" {
  value = "${module.account_settings.minimum_password_length}"
}

output "signin_url" {
  value = "${module.account_settings.signin_url}"
}
