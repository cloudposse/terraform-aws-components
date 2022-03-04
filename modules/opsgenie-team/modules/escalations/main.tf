locals {
#  [for f in local.slo_files : yamldecode(file(f))]
  lookup_team_arr = [for recipient in var.escalation.rule.recipients : recipient if recipient.type == "team"]
  lookup_team_names = [for r in local.lookup_team_arr: r.team_name]
#  lookup_team_map = {for r in local.lookup_team_arr: r.team_name->data.}
}

data "opsgenie_team" "recipients" {
  for_each = toset(local.lookup_team_names)
  name = each.value
}

resource "opsgenie_escalation" "this" {
  count = module.this.enabled ? 1 : 0

  name          = var.escalation.name
  description   = try(var.escalation.description, var.escalation.name)
  owner_team_id = try(var.escalation.owner_team_id, null)

  rules {
    condition   = try(var.escalation.rule.condition, "if-not-acked")
    notify_type = try(var.escalation.rule.notify_type, "default")
    delay       = try(var.escalation.rule.delay, 0)

    dynamic "recipient" {
      for_each = try(var.escalation.rule.recipients, [])

      content {
        id   = data.opsgenie_team.recipients[recipient.value.team_name].id
        type = recipient.value.type
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
