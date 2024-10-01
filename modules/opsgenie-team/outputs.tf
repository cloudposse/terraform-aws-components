output "team_members" {
  value       = local.enabled ? module.members_merge.*.merged : null
  description = "Team members"
}

output "team_name" {
  value       = local.enabled ? local.team_name : null
  description = "Team Name"
}

output "team_id" {
  value       = local.team_id
  description = "Team ID"
}

output "integration" {
  value       = local.enabled ? module.integration : null
  description = "Integrations created"
}

output "routing" {
  value       = local.enabled ? module.routing : null
  description = "Routing rules created"
}

output "escalation" {
  value       = local.enabled ? module.escalation : null
  description = "Escalation rules created"
}
