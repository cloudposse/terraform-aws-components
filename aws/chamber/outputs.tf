output "chamber_kms_key_arn" {
  value       = "${module.chamber_kms_key.key_arn}"
  description = "KMS key ARN"
}

output "chamber_kms_key_id" {
  value       = "${module.chamber_kms_key.key_id}"
  description = "KMS key ID"
}

output "chamber_kms_key_alias_arn" {
  value       = "${module.chamber_kms_key.alias_arn}"
  description = "KMS key alias ARN"
}

output "chamber_kms_key_alias_name" {
  value       = "${module.chamber_kms_key.alias_name}"
  description = "KMS key alias name"
}

output "chamber_user_name" {
  value       = "${module.chamber_user.user_name}"
  description = "Normalized IAM user name"
}

output "chamber_user_arn" {
  value       = "${module.chamber_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "chamber_user_unique_id" {
  value       = "${module.chamber_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "chamber_access_key_id" {
  value       = "${module.chamber_user.access_key_id}"
  description = "The access key ID"
}

output "chamber_secret_access_key" {
  value       = "${module.chamber_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}
