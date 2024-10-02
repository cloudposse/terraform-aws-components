locals {
  enabled = module.this.enabled

  is_type_datadog = lower(var.type) == "datadog"

  # Fully qualified integration name with tenant and team
  name = module.integration_name.id

  ssm_path = format(var.ssm_path_format, local.name)

  team_id = join("", data.opsgenie_team.default.*.id)

  append_datadog_tags_enabled = local.enabled && local.is_type_datadog && var.append_datadog_tags_enabled
}

# Fully qualified integration name normalized
module "integration_name" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # Remove these from the identifier to prevent integration names from containing extraneous information
  # This will prevent an integration name of `<namespace>-<tenant>-<environment>-<stage>-team-sre` and reduce it to simply `team-sre`
  # This is useful for the type Datadog integration where the name is used with the `@opsgenie-<integration>` within a Datadog alert message
  namespace   = ""
  tenant      = ""
  environment = ""
  stage       = ""

  context = module.this.context
}

data "opsgenie_team" "default" {
  count = local.enabled ? 1 : 0

  name = var.team_name
}

module "api_integration" {
  source  = "cloudposse/incident-management/opsgenie//modules/api_integration"
  version = "0.16.0"

  # TODO: add additional parameters to api integrations
  api_integration = {
    name          = local.name
    type          = var.type
    owner_team_id = local.team_id
  }

  context = module.this.context
}

resource "opsgenie_integration_action" "datadog" {
  # TODO: use upstream module instead of raw resource
  # source  = "cloudposse/incident-management/opsgenie//modules/integration_action"
  # version = "0.14.4"

  count = local.append_datadog_tags_enabled ? 1 : 0

  integration_id = module.api_integration.api_integration_id

  create {
    ignore_responders_from_payload = true

    name          = "Create Metric Alert"
    order         = 1
    alias         = "{{alias}}"
    tags          = ["{{dd_tags}}"]
    user          = "Datadog"
    note          = "{{note}}"
    source        = "{{source}}"
    message       = "[Datadog] {{monitor_name}}"
    entity        = "{{entity}}"
    alert_actions = []

    # The Datadog description is null so we use the DD Message as the description
    description = "{{templated_message}}\n"
    extra_properties = {
      "Event Url" : "{{event_url}}"
      "Snapshot Link" : "{{snapshot_link}}"
      "Metric Graph" : "<img src=\"{{snapshot_url}}\"/>"
      "Datadog Tags" : "{{dd_tags}}"
    }

    # Note, this does NOT match the docs found in terraform
    ## https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/integration_action#filter
    # Instead we find the actual working fields from the debug section of Opsgenie.
    filter {
      type = "match-all-conditions"

      # The order of these filter rules matter or it can create an inconsistent plan. It seems like it's alphabetically
      # ordered by the conditions field.

      conditions {
        # not `actions` as described in the TF docs
        field          = "action"
        operation      = "equals"
        expected_value = "create"
      }

      # Specifically do not check for dd_tags, contains, team:${var.team_name} so other teams can reuse a team integration. Also @opsgenie-<team> already controls what integration the alert is sent to.

      # We purposely do not check for tenant/stage since this is controlled by the Datadog organizations
      # and how the datadog organizations are configured. 1 per tenant, 1 per account, single org, etc.

      conditions {
        # not `source` as described in the TF docs
        field          = "event_type"
        operation      = "equals"
        expected_value = "query_alert_monitor"
      }

    }

    responders {
      id   = local.team_id
      type = "team"
    }
  }

  create {
    ignore_responders_from_payload = true

    name  = "Create Synthetic Alert"
    order = 2

    # Only add the Statuspage component and incident ID tags.
    # If all of dd_tags is added, then the alert will be polluted with probe_ tags, which are not necessary in OpsGenie,
    # and also cause the alert's tag count to exceed the limit (20). This then prevents the Statuspage integration from
    # appending the incident_id tag, which is required for bidirectional OpsGenie <-> Statuspage communication.
    tags = [
      "{{ dd_tags.substringBetween(\"cmp_\",\",\") }}",
      "{{ dd_tags.substringBetween(\"incident_id:\",\",\") }}"
    ]
    user          = "Datadog"
    note          = "{{note}}"
    alias         = "{{alias}}"
    source        = "{{source}}"
    message       = "{{monitor_name.substringAfter(\"[Synthetics]\")}}"
    entity        = "{{entity}}"
    alert_actions = []

    description = "{{templated_message.substringBefore(\"@\")}}\n"
    extra_properties = {
      "Event Url" : "{{event_url}}"
    }

    filter {
      type = "match-all-conditions"

      conditions {
        # not `actions` as described in the TF docs
        field          = "action"
        operation      = "equals"
        expected_value = "create"
      }

      conditions {
        # not `source` as described in the TF docs
        field          = "event_type"
        operation      = "equals"
        expected_value = "synthetics_alert"
      }

    }

    responders {
      id   = local.team_id
      type = "team"
    }
  }

  # Close Action of a Metric Alert from Datadog
  close {
    name  = "Close Alert"
    alias = "{{alias}}"
    user  = "{{user}}"
    note  = "{{note}}"

    # Note, this does NOT match the docs found in terraform
    ## https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/integration_action#filter
    # Instead we find the actual working fields from the debug section of Opsgenie.
    filter {
      type = "match-all-conditions"

      # The order of these filter rules matter or it can create an inconsistent plan. It seems like it's alphabetically
      # ordered by the conditions field.

      conditions {
        # not `actions` as described in the TF docs
        field          = "action"
        operation      = "equals"
        expected_value = "close"
      }
    }
  }

  # Acknowledge Action of a Metric Alert from Datadog
  acknowledge {
    name  = "Acknowledge Alert"
    alias = "{{alias}}"
    user  = "{{user_handle}}"
    note  = "{{templated_message}}"

    # Note, this does NOT match the docs found in terraform
    ## https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/integration_action#filter
    # Instead we find the actual working fields from the debug section of Opsgenie.
    filter {
      type = "match-all-conditions"

      # The order of these filter rules matter or it can create an inconsistent plan. It seems like it's alphabetically
      # ordered by the conditions field.

      conditions {
        # not `actions` as described in the TF docs
        field          = "action"
        operation      = "equals"
        expected_value = "acknowledge"
      }
    }
  }
}

# Populate SSM Parameter Store with API Keys for OpsGenie API Integrations.
# These keys can either be used when setting up OpsGenie integrations manually,
# Or they can be used programmatically, if their respective Terraform provider supports it.
module "ssm_parameter_store" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.11.0"

  # KMS key is only applied to SecureString params
  # https://github.com/cloudposse/terraform-aws-ssm-parameter-store/blob/master/main.tf#L17
  kms_arn = var.kms_key_arn

  parameter_write = [
    {
      description = "API Key for Opsgenie ${local.name} API Integration"
      name        = local.ssm_path
      overwrite   = true
      type        = "SecureString"
      value       = module.api_integration.api_integration_api_key
    }
  ]

  context = module.this.context
}
