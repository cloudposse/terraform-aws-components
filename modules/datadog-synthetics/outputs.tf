output "datadog_synthetics_tests" {
  value       = module.datadog_synthetics.datadog_synthetic_tests
  description = "The synthetic tests created in Datadog"
}

output "datadog_synthetics_test_names" {
  value       = module.datadog_synthetics.datadog_synthetics_test_names
  description = "Names of the created Datadog synthetic tests"
}

output "datadog_synthetics_test_ids" {
  value       = module.datadog_synthetics.datadog_synthetics_test_ids
  description = "IDs of the created Datadog synthetic tests"
}

output "datadog_synthetics_test_monitor_ids" {
  value       = module.datadog_synthetics.datadog_synthetics_test_monitor_ids
  description = "IDs of the monitors associated with the Datadog synthetics tests"
}
