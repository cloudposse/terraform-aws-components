module "second_app" {
  source           = "../../../terraform_modules/terraform-aws-chamber-s3-iam-role/"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "s3"
  attributes       = ["builds"]
  region           = "${data.aws_region.default.name}"
  account_id       = "${data.aws_caller_identity.default.account_id}"
  assume_role_arns = [
    "${module.kops_metadata.masters_role_arn}",
    "${module.kops_metadata.nodes_role_arn}",
  ]
  kms_key_arn      = "${module.chamber_kms_key.key_arn}"
  s3_bucket_arn   = "${module.chamber_s3_bucket.bucket_arn}"
  service_name     = "my-second-service"
}

output "role_name_2" {
  value       = "${module.second_app.role_name}"
  description = "The name of the created role"
}

output "role_id_2" {
  value       = "${module.second_app.role_id}"
  description = "The stable and unique string identifying the role"
}

output "role_arn_2" {
  value       = "${module.second_app.role_arn}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}
