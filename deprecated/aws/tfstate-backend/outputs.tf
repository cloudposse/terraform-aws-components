output "tfstate_backend_s3_bucket_domain_name" {
  value = "${module.tfstate_backend.s3_bucket_domain_name}"
}

output "tfstate_backend_s3_bucket_id" {
  value = "${module.tfstate_backend.s3_bucket_id}"
}

output "tfstate_backend_s3_bucket_arn" {
  value = "${module.tfstate_backend.s3_bucket_arn}"
}

output "tfstate_backend_dynamodb_table_name" {
  value = "${module.tfstate_backend.dynamodb_table_name}"
}

output "tfstate_backend_dynamodb_table_id" {
  value = "${module.tfstate_backend.dynamodb_table_id}"
}

output "tfstate_backend_dynamodb_table_arn" {
  value = "${module.tfstate_backend.dynamodb_table_arn}"
}
