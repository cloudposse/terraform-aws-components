output "docs_user_name" {
  value       = "${module.docs_user.user_name}"
  description = "Normalized IAM user name"
}

output "docs_user_arn" {
  value       = "${module.docs_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "docs_user_unique_id" {
  value       = "${module.docs_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "docs_user_access_key_id" {
  value       = "${module.docs_user.access_key_id}"
  description = "The access key ID"
}

output "docs_user_secret_access_key" {
  value       = "${module.docs_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "docs_s3_bucket_name" {
  value = "${module.origin.s3_bucket_name}"
}

output "docs_s3_bucket_domain_name" {
  value = "${module.origin.s3_bucket_domain_name}"
}

output "docs_s3_bucket_arn" {
  value = "${module.origin.s3_bucket_arn}"
}

output "docs_s3_bucket_website_endpoint" {
  value = "${module.origin.s3_bucket_website_endpoint}"
}

output "docs_s3_bucket_website_domain" {
  value = "${module.origin.s3_bucket_website_domain}"
}

output "docs_s3_bucket_hosted_zone_id" {
  value = "${module.origin.s3_bucket_hosted_zone_id}"
}

output "docs_cloudfront_id" {
  value = "${module.cdn.cf_id}"
}

output "docs_cloudfront_arn" {
  value = "${module.cdn.cf_arn}"
}

output "docs_cloudfront_aliases" {
  value = "${module.cdn.cf_aliases}"
}

output "docs_cloudfront_status" {
  value = "${module.cdn.cf_status}"
}

output "docs_cloudfront_domain_name" {
  value = "${module.cdn.cf_domain_name}"
}

output "docs_cloudfront_etag" {
  value = "${module.cdn.cf_etag}"
}

output "docs_cloudfront_hosted_zone_id" {
  value = "${module.cdn.cf_hosted_zone_id}"
}

output "docs_cloudfront_origin_access_identity_path" {
  value = "${module.cdn.cf_origin_access_identity}"
}
