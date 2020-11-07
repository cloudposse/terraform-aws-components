module "cloudtrail" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=tags/0.14.0"

  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_logs.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_cloudwatch_logs.arn}:*"
  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  s3_bucket_name                = data.terraform_remote_state.cloudtrail_bucket.outputs.cloudtrail_bucket_id

  context = module.this.context
}
