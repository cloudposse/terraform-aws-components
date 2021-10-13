variable "flow_logs_enabled" {
  type    = "string"
  default = "true"
}

module "flow_logs" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc-flow-logs-s3-bucket.git?ref=tags/0.1.1"
  name       = "kops"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  attributes = "${list("flow-logs")}"

  region = "${var.region}"

  enabled = "${var.flow_logs_enabled}"

  vpc_id = "${module.kops_metadata.vpc_id}"
}

output "flow_logs_kms_key_arn" {
  value       = "${module.flow_logs.kms_key_arn}"
  description = "Flow logs KMS Key ARN"
}

output "flow_logs_kms_key_id" {
  value       = "${module.flow_logs.kms_key_id}"
  description = "Flow logs KMS Key ID"
}

output "flow_logs_kms_alias_arn" {
  value       = "${module.flow_logs.kms_alias_arn}"
  description = "Flow logs KMS Alias ARN"
}

output "flow_logs_kms_alias_name" {
  value       = "${module.flow_logs.kms_alias_name}"
  description = "Flow logs KMS Alias name"
}

output "flow_logs_bucket_domain_name" {
  value       = "${module.flow_logs.bucket_domain_name}"
  description = "Flow logs FQDN of bucket"
}

output "flow_logs_bucket_id" {
  value       = "${module.flow_logs.bucket_id}"
  description = "Flow logs bucket Name (aka ID)"
}

output "flow_logs_bucket_arn" {
  value       = "${module.flow_logs.bucket_arn}"
  description = "Flow logs bucket ARN"
}

output "flow_logs_bucket_prefix" {
  value       = "${module.flow_logs.bucket_prefix}"
  description = "Flow logs bucket prefix configured for lifecycle rules"
}

output "flow_logs_id" {
  value       = "${module.flow_logs.id}"
  description = "Flow logs ID"
}
