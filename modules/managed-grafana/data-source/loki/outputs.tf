output "uid" {
  # The output id is not the uid. It follows a format like "1:uid"
  value       = split(":", grafana_data_source.loki[0].id)[1]
  description = "The UID of this dashboard"
}
