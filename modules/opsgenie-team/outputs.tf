output "team_members" {
  value       = local.enabled ? module.members_merge.*.merged : null
  description = "Team members"
}

output "team_name" {
  value       = local.team_name
  description = "Team Name"
}

output "team_id" {
  value       = local.team_id
  description = "Team ID"
}

output "integration" {
  value       = module.integration
  description = "Integrations created"
}

output "routing" {
  value       = module.routing
  description = "Routing rules created"
}
