output "name" {
  description = "Name of the Global Accelerator."
  value       = module.global_accelerator.name
}

output "dns_name" {
  description = "DNS name of the Global Accelerator."
  value       = module.global_accelerator.dns_name
}

output "listener_ids" {
  description = "Global Accelerator Listener IDs."
  value       = module.global_accelerator.listener_ids
}

output "static_ips" {
  description = "Global Static IPs owned by the Global Accelerator."
  value       = module.global_accelerator.static_ips
}
