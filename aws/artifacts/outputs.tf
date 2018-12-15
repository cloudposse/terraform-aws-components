output "artifacts_user_name" {
  value       = "${module.artifacts_user.user_name}"
  description = "Normalized IAM user name"
}

output "artifacts_user_arn" {
  value       = "${module.artifacts_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "artifacts_user_unique_id" {
  value       = "${module.artifacts_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "artifacts_user_access_key_id" {
  value       = "${module.artifacts_user.access_key_id}"
  description = "The access key ID"
}

output "artifacts_user_secret_access_key" {
  value       = "${module.artifacts_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "artifacts_s3_bucket_name" {
  value = "${module.origin.s3_bucket_name}"
}

output "artifacts_s3_bucket_domain_name" {
  value = "${module.origin.s3_bucket_domain_name}"
}

output "artifacts_s3_bucket_arn" {
  value = "${module.origin.s3_bucket_arn}"
}

output "artifacts_s3_bucket_website_endpoint" {
  value = "${module.origin.s3_bucket_website_endpoint}"
}

output "artifacts_s3_bucket_website_domain" {
  value = "${module.origin.s3_bucket_website_domain}"
}

output "artifacts_s3_bucket_hosted_zone_id" {
  value = "${module.origin.s3_bucket_hosted_zone_id}"
}

output "artifacts_cloudfront_id" {
  value = "${module.cdn.cf_id}"
}

output "artifacts_cloudfront_arn" {
  value = "${module.cdn.cf_arn}"
}

output "artifacts_cloudfront_aliases" {
  value = "${module.cdn.cf_aliases}"
}

output "artifacts_cloudfront_status" {
  value = "${module.cdn.cf_status}"
}

output "artifacts_cloudfront_domain_name" {
  value = "${module.cdn.cf_domain_name}"
}

output "artifacts_cloudfront_etag" {
  value = "${module.cdn.cf_etag}"
}

output "artifacts_cloudfront_hosted_zone_id" {
  value = "${module.cdn.cf_hosted_zone_id}"
}

output "artifacts_cloudfront_origin_access_identity_path" {
  value = "${module.cdn.cf_origin_access_identity}"
}
