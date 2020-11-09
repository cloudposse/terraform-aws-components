output "datadog_monitor_names" {
  value       = module.datadog_monitors.datadog_monitor_names
  description = "Names of the created Datadog monitors"
}
