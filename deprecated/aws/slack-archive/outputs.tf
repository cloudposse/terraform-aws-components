output "slack_archive_user_name" {
  value       = "${module.slack_archive_user.user_name}"
  description = "Normalized IAM user name"
}

output "slack_archive_user_arn" {
  value       = "${module.slack_archive_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "slack_archive_user_unique_id" {
  value       = "${module.slack_archive_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "slack_archive_user_access_key_id" {
  value       = "${module.slack_archive_user.access_key_id}"
  description = "The access key ID"
  sensitive   = true
}

output "slack_archive_user_secret_access_key" {
  value       = "${module.slack_archive_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
  sensitive   = true
}

output "slack_archive_s3_bucket_name" {
  value = "${module.origin.s3_bucket_name}"
}

output "slack_archive_s3_bucket_domain_name" {
  value = "${module.origin.s3_bucket_domain_name}"
}

output "slack_archive_s3_bucket_arn" {
  value = "${module.origin.s3_bucket_arn}"
}

output "slack_archive_s3_bucket_website_endpoint" {
  value = "${module.origin.s3_bucket_website_endpoint}"
}

output "slack_archive_s3_bucket_website_domain" {
  value = "${module.origin.s3_bucket_website_domain}"
}

output "slack_archive_s3_bucket_hosted_zone_id" {
  value = "${module.origin.s3_bucket_hosted_zone_id}"
}

output "slack_archive_cloudfront_id" {
  value = "${module.cdn.cf_id}"
}

output "slack_archive_cloudfront_arn" {
  value = "${module.cdn.cf_arn}"
}

output "slack_archive_cloudfront_aliases" {
  value = "${module.cdn.cf_aliases}"
}

output "slack_archive_cloudfront_status" {
  value = "${module.cdn.cf_status}"
}

output "slack_archive_cloudfront_domain_name" {
  value = "${module.cdn.cf_domain_name}"
}

output "slack_archive_cloudfront_etag" {
  value = "${module.cdn.cf_etag}"
}

output "slack_archive_cloudfront_hosted_zone_id" {
  value = "${module.cdn.cf_hosted_zone_id}"
}

output "slack_archive_cloudfront_origin_access_identity_path" {
  value = "${module.cdn.cf_origin_access_identity}"
}
