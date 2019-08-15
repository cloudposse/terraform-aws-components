module "cloudtrail_s3_bucket" {
  source             = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-s3-bucket.git?ref=0.11/logging"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  region             = "${local.region}"
  sse_algorithm      = "aws:kms"
  kms_master_key_arn = "${module.kms_key_s3_bucket.alias_arn}"
}

module "kms_key_s3_bucket" {
  source    = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=0.1.3"
  namespace = "${var.namespace}"
  name      = "${var.name}"
  stage     = "${var.stage}"

  attributes = ["cloudtrail", "s3", "bucket"]

  description             = "KMS key for CloudTrail S3 Bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"
}
