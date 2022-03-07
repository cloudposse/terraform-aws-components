locals {
  enabled = module.this.enabled

  create_all_enabled = local.enabled && var.create_only_integrations_enabled == false

  # Team locals to maintain an implicit dependency to downstream modules
  team_id   = var.create_only_integrations_enabled ? join("", data.opsgenie_team.existing.*.id) : module.team.team_id
  team_name = var.create_only_integrations_enabled ? join("", data.opsgenie_team.existing.*.name) : coalesce(module.team.team_name, var.name)

  members = {
    for member in var.members :
    member.user => {
      username : member.user,
      role : try(member.role, null),
    }
  }
}

data "opsgenie_team" "existing" {
  count = local.enabled && var.create_only_integrations_enabled ? 1 : 0

  name = module.this.name
}

data "opsgenie_user" "team_members" {
  for_each = local.enabled ? {
    for member in var.members :
    member.user => member
  } : {}

  username = each.key
}

module "members_merge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.8.1"

  # Cannot use context to disable
  # See issue: https://github.com/cloudposse/terraform-yaml-config/issues/18
  count = local.enabled ? 1 : 0

  maps = [
    data.opsgenie_user.team_members,
    local.members,
  ]

  # context = module.introspection.context
}

module "team" {
  source  = "cloudposse/incident-management/opsgenie//modules/team"
  version = "0.15.0"

  # Only create if not reusing an existing team
  enabled = local.create_all_enabled

  team = {
    name           = module.this.name
    description    = var.description
    members        = try(module.members_merge[0].merged, [])
    ignore_members = var.ignore_team_members
  }

  context = module.introspection.context
}

module "integration" {
  source = "./modules/integration"

  // We add Datadog here because we need the core input for the team.
  // Can be overridden by var.integrations.datadog
  for_each = merge({
    datadog : {
      type : "Datadog"
    }
  }, var.integrations)

  type = each.value.type

  # name of the integration is really just a prefix
  name = format("%s%s%s", "team", module.this.delimiter, local.team_name)

  # Append type and name to each integration except when it's Datadog
  # The reason to not add the Datadog is because this will affect the @opsgenie-<integration> tag
  # which we want to keep as e.g. @opsgenie-team-sre instead of @opsgenie-team-sre-datadog
  attributes = lower(each.value.type) != "datadog" ? [
    each.value.type,
    each.key,
  ] : []

  team_name = local.team_name

  kms_key_arn = var.kms_key_arn

  # Allow underscores in the identifier
  regex_replace_chars = "/[^a-zA-Z0-9-_]/"

  context = module.introspection.context

  depends_on = [module.team]
}

module "service" {
  source  = "cloudposse/incident-management/opsgenie//modules/service"
  version = "0.15.0"

  for_each = var.services

  # Only create if not reusing an existing team
  enabled = local.create_all_enabled

  service = {
    name        = each.key
    team_id     = local.team_id
    description = lookup(each.value, "description", null)
  }

  context = module.introspection.context

  depends_on = [module.team]
}

module "schedule" {
  source  = "cloudposse/incident-management/opsgenie//modules/schedule"
  version = "0.15.0"

  for_each = {
    for k, v in var.schedules :
    k => v
    if try(v.enabled == true, false)
  }

  # Only create if not reusing an existing team
  enabled = local.create_all_enabled

  schedule = {
    name          = try(each.key, null)
    description   = try(each.value.description, null)
    timezone      = try(each.value.timezone, null)
    owner_team_id = local.team_id
  }

  context = module.introspection.context

  depends_on = [module.team]
}

module "routing" {
  source = "./modules/routing"

  for_each = {
    for k, v in var.routing_rules :
    k => v
    if try(v.enabled == true, false)
  }

  # Only create if not reusing an existing team
  enabled = local.create_all_enabled

  team_name = local.team_name
  name      = each.key

  criteria = try(each.value.criteria, null)
  type     = try(each.value.type, null)
  notify   = try(each.value.notify, null)
  order    = try(each.value.order, null)
  priority = try(each.value.priority, null)

  # We send the map of services
  services = var.services

  # This requires a default or OpsGenie will add one which leads to inconsistent plans
  timezone         = try(each.value.timezone, "America/New_York")
  time_restriction = try(each.value.time_restriction, null)

  incident_properties = try(each.value.incident_properties, null)

  # Allow underscores in the name
  regex_replace_chars = "/[^a-zA-Z0-9-_]/"

  context = module.introspection.context

  depends_on = [
    module.team,
    module.schedule,
    module.service
  ]
}

module "escalations" {
  source = "./modules/escalations"

  for_each = {
    for k, v in var.escalations :
    k => v
    if try(v.enabled == true, false)
  }

  # Only create if not reusing an existing team
  enabled = local.create_all_enabled

  escalation = {
    name          = try(each.key, null)
    owner_team_id = local.team_id

    description = try(each.value.description, null)

    rule   = try(each.value.rule, null)
    repeat = try(each.value.repeat, null)
  }

  context = module.introspection.context

  depends_on = [module.team]
}
