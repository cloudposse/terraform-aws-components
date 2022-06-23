locals {
  lookup_teams = distinct(flatten([
    for rule in var.escalation.rules : [
      for recipient in rule.recipients :
      recipient.name
      if recipient.type == "team"
    ]
  ]))
  lookup_users = distinct(flatten([
    for rule in var.escalation.rules : [
      for recipient in rule.recipients :
      recipient.name
      if recipient.type == "user"
    ]
  ]))
  lookup_schedules = distinct(flatten([
    for rule in var.escalation.rules : [
      for recipient in rule.recipients :
      recipient.name
      if recipient.type == "schedule"
    ]
  ]))
}

data "opsgenie_team" "recipients" {
  for_each = toset(local.lookup_teams)
  name     = each.value
}

data "opsgenie_user" "recipients" {
  for_each = toset(local.lookup_users)
  username = each.value
}

data "opsgenie_schedule" "recipients" {
  for_each = toset(local.lookup_schedules)
  name     = each.value
}

# TODO: use https://github.com/cloudposse/terraform-opsgenie-incident-management/tree/master/modules/escalation
resource "opsgenie_escalation" "this" {
  count = module.this.enabled ? 1 : 0

  name          = var.escalation.name
  description   = try(var.escalation.description, var.escalation.name)
  owner_team_id = try(var.escalation.owner_team_id, null)

  dynamic "rules" {
    for_each = try(var.escalation.rules, [])

    content {
      condition   = try(rules.value.condition, "if-not-acked")
      notify_type = try(rules.value.notify_type, "default")
      delay       = try(rules.value.delay, 0)

      dynamic "recipient" {
        for_each = try(rules.value.recipients, [])

        content {
          id   = recipient.value.type == "team" ? data.opsgenie_team.recipients[recipient.value.name].id : recipient.value.type == "schedule" ? data.opsgenie_schedule.recipients[recipient.value.name].id : data.opsgenie_user.recipients[recipient.value.name].id
          type = recipient.value.type
        }
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
