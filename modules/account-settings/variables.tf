variable "region" {
  type        = string
  description = "AWS Region"
}

variable "minimum_password_length" {
  type        = string
  default     = 14
  description = "Minimum number of characters allowed in an IAM user password. Integer between 6 and 128, per https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html"
}

variable "maximum_password_age" {
  type        = number
  default     = 190
  description = "The number of days that an user password is valid"
}
