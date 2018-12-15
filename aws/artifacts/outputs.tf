output "access_key_id" {
  value       = "${module.user.access_key_id}"
  description = "The access key ID for the user with permission to read/write to this bucket."
}

output "secret_access_key" {
  value       = "${module.user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text."
}

output "bucket_name" {
  value = "${module.bucket.bucket_id}"
}
