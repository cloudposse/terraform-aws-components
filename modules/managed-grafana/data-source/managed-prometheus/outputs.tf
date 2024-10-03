output "uid" {
  # The output "id" includes orgId (orgId:uid). We only want uid
  value       = split(":", grafana_data_source.managed_prometheus[0].id)[1]
  description = "The UID of this dashboard"
}
