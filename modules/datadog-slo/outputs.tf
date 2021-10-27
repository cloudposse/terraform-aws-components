output "datadog_monitor_slos" {
  value       = module.datadog_slos.datadog_monitor_slos
  description = "Map of created Monitor Based SLOs"
}

output "datadog_metric_slos" {
  value       = module.datadog_slos.datadog_metric_slos
  description = "Map of created Metric Based SLOs"
}

output "datadog_slo_alerts" {
  value       = module.datadog_slos.datadog_slo_alerts
  description = "Map of created SLO Based Alerts"
}
