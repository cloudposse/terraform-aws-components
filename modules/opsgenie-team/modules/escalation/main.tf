locals {
  enabled = module.this.enabled && var.escalation != null && length(var.escalation.rules) > 0
  lookup_teams = local.enabled ? distinct(flatten([
    for rule in var.escalation.rules :
    rule.recipient.name
    if rule.recipient.type == "team"
  ])) : []
  lookup_users = local.enabled ? distinct(flatten([
    for rule in var.escalation.rules :
    rule.recipient.name
    if rule.recipient.type == "user"
  ])) : []
  lookup_schedules = local.enabled ? distinct(flatten([
    for rule in var.escalation.rules :
    format(var.team_naming_format, var.team_name, rule.recipient.name)
    if rule.recipient.type == "schedule" && module.this.enabled
  ])) : []
}

data "opsgenie_team" "recipient" {
  for_each = toset(local.lookup_teams)
  name     = each.value
}

data "opsgenie_user" "recipient" {
  for_each = toset(local.lookup_users)
  username = each.value
}

data "opsgenie_schedule" "recipient" {
  for_each = toset(local.lookup_schedules)
  name     = each.value
}

# TODO: use https://github.com/cloudposse/terraform-opsgenie-incident-management/tree/master/modules/escalation
resource "opsgenie_escalation" "this" {
  count = module.this.enabled ? 1 : 0

  name          = format(var.team_naming_format, var.team_name, var.escalation.name)
  description   = try(var.escalation.description, var.escalation.name)
  owner_team_id = try(var.escalation.owner_team_id, null)

  dynamic "rules" {
    for_each = try(var.escalation.rules, [])

    content {
      condition   = try(rules.value.condition, "if-not-acked")
      notify_type = try(rules.value.notify_type, "default")
      delay       = try(rules.value.delay, 0)

      # In spite of the docs, only one recipient can be used per escalation resource with multiple rules
      recipient {
        id   = rules.value.recipient.type == "team" ? data.opsgenie_team.recipient[rules.value.recipient.name].id : rules.value.recipient.type == "schedule" ? data.opsgenie_schedule.recipient[format(var.team_naming_format, var.team_name, rules.value.recipient.name)].id : data.opsgenie_user.recipient[rules.value.recipient.name].id
        type = rules.value.recipient.type
      }
    }
  }

  dynamic "repeat" {
    for_each = try(var.escalation.repeat, null) != null ? ["true"] : []

    content {
      wait_interval          = lookup(var.escalation.repeat, "wait_interval", 5)
      count                  = lookup(var.escalation.repeat, "count", 0)
      reset_recipient_states = lookup(var.escalation.repeat, "reset_recipient_states", true)
      close_alert_after_all  = lookup(var.escalation.repeat, "close_alert_after_all", true)
    }
  }
}
