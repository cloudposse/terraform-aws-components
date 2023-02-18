locals {
  enabled = module.this.enabled

  team_alert_rule_enabled       = local.enabled && var.type == "alert"
  service_incident_rule_enabled = local.enabled && var.type == "incident"

  # Schedule is only used for alert
  notify_schedule_enabled = local.team_alert_rule_enabled && try(var.notify.type == "schedule", true)

  schedule_name = try(var.notify.name, null)

  # Routing rule name has <team>_<name> format
  # team_routing_rule_name = format("%s_%s", var.team_name, var.name)
  team_routing_rule_name = module.this.name
}

data "opsgenie_team" "default" {
  count = local.enabled ? 1 : 0

  name = var.team_name
}

data "opsgenie_schedule" "notification_schedule" {
  count = local.team_alert_rule_enabled && local.notify_schedule_enabled ? 1 : 0

  name = local.schedule_name
}

data "opsgenie_service" "incident_service" {
  for_each = local.service_incident_rule_enabled ? var.services : {}

  name = each.key
}

module "team_routing_rule" {
  source  = "cloudposse/incident-management/opsgenie//modules/team_routing_rule"
  version = "0.16.0"

  count = local.team_alert_rule_enabled ? 1 : 0

  team_routing_rule = {
    name    = local.team_routing_rule_name
    team_id = join("", data.opsgenie_team.default.*.id)

    order = var.order

    notify = [{
      type = var.notify.type
      name = try(format(var.team_naming_format, var.team_name, var.notify.name), null)
      id   = try(join("", data.opsgenie_schedule.notification_schedule.*.id), "")
    }]

    criteria = {
      type       = try(var.criteria.type, null)
      conditions = try(var.criteria.conditions, null)
    }

    timezone         = var.timezone
    time_restriction = var.time_restriction
  }

  context = module.this.context
}

locals {
  default_service = { for k, v in var.services : k => v if k == "default_service" }
  services        = { for k, v in var.services : k => v if k != "default_service" }
}

module "service_incident_rule" {
  source  = "cloudposse/incident-management/opsgenie//modules/service_incident_rule"
  version = "0.16.0"

  for_each = local.service_incident_rule_enabled ? local.services : {}

  service_incident_rule = {
    service_id = data.opsgenie_service.incident_service[each.key].id

    incident_rule = {
      condition_match_type = var.criteria.type
      conditions = concat(try(var.criteria.conditions, null), [{
        field          = "tags"
        operation      = "contains"
        expected_value = "service:${each.key}"
      }])

      incident_properties = {
        message = try(var.incident_properties.message, "{{message}}")
        tags    = try(var.incident_properties.tags, [])
        details = try(var.incident_properties.details, {})

        priority = var.priority

        stakeholder_properties = {
          message     = try(var.incident_properties.message, "{{message}}")
          description = try(var.incident_properties.description, null)
          enable      = try(var.incident_properties.update_stakeholders, true)
        }
      }
    }
  }

  context = module.this.context
}


module "serviceless_incident_rule" {
  source  = "cloudposse/incident-management/opsgenie//modules/service_incident_rule"
  version = "0.16.0"

  depends_on = [data.opsgenie_service.incident_service]

  for_each = local.service_incident_rule_enabled ? local.default_service : {}

  service_incident_rule = {
    service_id = data.opsgenie_service.incident_service[each.key].id

    incident_rule = {
      condition_match_type = var.criteria.type
      conditions           = try(var.criteria.conditions, null)

      incident_properties = {
        message = try(var.incident_properties.message, "{{message}}")
        tags    = try(var.incident_properties.tags, [])
        details = try(var.incident_properties.details, {})

        priority = var.priority

        stakeholder_properties = {
          message     = try(var.incident_properties.message, "{{message}}")
          description = try(var.incident_properties.description, null)
          enable      = try(var.incident_properties.update_stakeholders, true)
        }
      }
    }
  }

  context = module.this.context
}
