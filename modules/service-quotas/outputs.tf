output "service_quotas" {
  value       = module.service_quotas.service_quotas
  description = "A list of all of the service quotas that this component interacted with"
}
