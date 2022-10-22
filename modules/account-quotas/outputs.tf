output "quotas" {
  value       = aws_servicequotas_service_quota.this
  description = "Full report on all service quotas managed by this component."
}
