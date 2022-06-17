output "team_routing_rule" {
  value       = module.team_routing_rule
  description = "Team routing rules for alerts"
}

output "service_incident_rule" {
  value       = module.service_incident_rule
  description = "Service incident rules for incidents"
}
