output "escalation_id" {
  description = "The ID of the Opsgenie Escalation"
  value       = try(opsgenie_escalation.this[0].id, null)
}

output "escalation_name" {
  description = "Name of the Opsgenie Escalation"
  value       = try(opsgenie_escalation.this[0].name, null)
}
