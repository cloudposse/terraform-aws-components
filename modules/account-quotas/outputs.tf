/*
output "service_codes" {
  value = data.aws_servicequotas_service.by_name
}

output "quota_codes" {
  value = data.aws_servicequotas_service_quota.by_name
}

output "quotas_coded_map" {
  value = local.quotas_coded_map
}
*/

output "quotas" {
  value = aws_servicequotas_service_quota.this
}
