variable "chamber_s3_enabled" {
  default     = "false"
  description = "Set to true to create S3 bucket for chamber"
}

variable "chamber_s3_user_enabled" {
  default     = "false"
  description = "Set to `true` to create an S3 user with permission to access the bucket"
}

module "chamber_s3_bucket" {
  source             = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.2.1"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "chamber"
  enabled            = "${var.chamber_s3_enabled}"
  versioning_enabled = "false"
  user_enabled       = "${var.chamber_s3_user_enabled}"
  sse_algorithm      = "aws:kms"
  kms_master_key_id  = "${module.chamber_kms_key.key_id}"
}

output "bucket_domain_name" {
  value       = "${module.chamber_s3_bucket.bucket_domain_name}"
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = "${module.chamber_s3_bucket.bucket_id}"
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = "${module.chamber_s3_bucket.bucket_arn}"
  description = "Bucket ARN"
}

output "enabled" {
  value       = "${module.chamber_s3_bucket.enabled}"
  description = "Is module enabled"
}

output "user_enabled" {
  value       = "${module.chamber_s3_bucket.user_enabled}"
  description = "Is user creation enabled"
}

output "user_name" {
  value       = "${module.chamber_s3_bucket.user_name}"
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = "${module.chamber_s3_bucket.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "user_unique_id" {
  value       = "${module.chamber_s3_bucket.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "access_key_id" {
  value       = "${module.chamber_s3_bucket.access_key_id}"
  description = "The access key ID"
}

output "secret_access_key" {
  value       = "${module.chamber_s3_bucket.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "s3_bucket_arn" {
  value       = "${module.chamber_s3_bucket.s3_bucket_arn}"
  description = "S3 bucket ARN"
}
