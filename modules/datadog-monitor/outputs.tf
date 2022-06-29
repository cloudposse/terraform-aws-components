output "datadog_monitor_names" {
  value       = local.datadog_monitors_enabled ? module.datadog_monitors[0].datadog_monitor_names : null
  description = "Names of the created Datadog monitors"
}
