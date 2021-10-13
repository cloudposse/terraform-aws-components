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
  value       = "${module.origin.s3_bucket_name}"
  description = "The S3 bucket which serves as the origin for the CDN and S3 website"
}

output "artifacts_s3_bucket_domain_name" {
  value       = "${module.origin.s3_bucket_domain_name}"
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
}

output "artifacts_s3_bucket_arn" {
  value       = "${module.origin.s3_bucket_arn}"
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
}

output "artifacts_s3_bucket_website_endpoint" {
  value       = "${module.origin.s3_bucket_website_endpoint}"
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
}

output "artifacts_s3_bucket_website_domain" {
  value       = "${module.origin.s3_bucket_website_domain}"
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records."
}

output "artifacts_s3_bucket_hosted_zone_id" {
  value       = "${module.origin.s3_bucket_hosted_zone_id}"
  description = "The Route 53 Hosted Zone ID for this bucket's region."
}

output "artifacts_cloudfront_id" {
  value       = "${module.cdn.cf_id}"
  description = "The identifier for the distribution. For example: EDFDVBD632BHDS5."
}

output "artifacts_cloudfront_arn" {
  value       = "${module.cdn.cf_arn}"
  description = "The ARN (Amazon Resource Name) for the distribution. For example: arn:aws:cloudfront::123456789012:distribution/EDFDVBD632BHDS5, where 123456789012 is your AWS account ID."
}

output "artifacts_cloudfront_aliases" {
  value       = "${module.cdn.cf_aliases}"
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
}

output "artifacts_cloudfront_status" {
  value       = "${module.cdn.cf_status}"
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
}

output "artifacts_cloudfront_domain_name" {
  value       = "${module.cdn.cf_domain_name}"
  description = "The domain name corresponding to the distribution. For example: d604721fxaaqy9.cloudfront.net."
}

output "artifacts_cloudfront_etag" {
  value       = "${module.cdn.cf_etag}"
  description = "The current version of the distribution's information. For example: E2QWRUHAPOMQZL."
}

output "artifacts_cloudfront_hosted_zone_id" {
  value       = "${module.cdn.cf_hosted_zone_id}"
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. This attribute is simply an alias for the zone ID Z2FDTNDATAQYW2."
}

output "artifacts_cloudfront_origin_access_identity_path" {
  value       = "${module.cdn.cf_origin_access_identity}"
  description = "The CloudFront origin access identity to associate with the origin."
}
