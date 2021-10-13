output "teleport_version" {
  value = "${var.teleport_version}"
}

output "teleport_proxy_domain_name" {
  value = "${var.teleport_proxy_domain_name}"
}

output "parameter_store_prefix" {
  value = "${format(var.chamber_parameter_name, local.chamber_service, "")}"
}

output "teleport_kubernetes_namespace" {
  value = "${var.kubernetes_namespace}"
}

output "teleport_auth_iam_role" {
  value = "${aws_iam_role.teleport.name}"
}

output "teleport_cluster_state_dynamodb_table" {
  value = "${module.teleport_backend.dynamodb_state_table_id}"
}

output "teleport_audit_sessions_uri" {
  value = "s3://${module.teleport_backend.s3_bucket_id}"
}

output "teleport_audit_events_uri" {
  value = "dynamodb://${module.teleport_backend.dynamodb_audit_table_id}"
}
