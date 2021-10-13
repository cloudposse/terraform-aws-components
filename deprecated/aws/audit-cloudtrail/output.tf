output "cloudtrail_kms_key_arn" {
  value = "${module.kms_key_cloudtrail.alias_arn}"
}

output "cloudtrail_bucket_domain_name" {
  value = "${module.cloudtrail_s3_bucket.bucket_domain_name}"
}

output "cloudtrail_bucket_id" {
  value = "${module.cloudtrail_s3_bucket.bucket_id}"
}

output "cloudtrail_bucket_arn" {
  value = "${module.cloudtrail_s3_bucket.bucket_arn}"
}
