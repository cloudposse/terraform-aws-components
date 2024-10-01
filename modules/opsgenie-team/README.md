---
tags:
  - component/opsgenie-team
  - layer/unassigned
  - provider/aws
---

# Component: `opsgenie-team`

This component is responsible for provisioning Opsgenie teams and related services, rules, schedules.

## Usage

#### Pre-requisites

You need an API Key stored in `/opsgenie/opsgenie_api_key` of SSM, this is configurable using the
`ssm_parameter_name_format` and `ssm_path` variables.

Opsgenie is now part of Atlassian, so you need to make sure you are creating an Opsgenie API Key, which looks like
`abcdef12-3456-7890-abcd-ef0123456789` and not an Atlassian API key, which looks like

```shell
ATAfT3xFfGF0VFXAfl8EmQNPVv1Hlazp3wsJgTmM8Ph7iP-RtQyiEfw-fkDS2LvymlyUOOhc5XiSx46vQWnznCJolq-GMX4KzdvOSPhEWr-BF6LEkJQC4CSjDJv0N7d91-0gVekNmCD2kXY9haUHUSpO4H7X6QxyImUb9VmOKIWTbQi8rf4CF28=63CB21B9
```

Generate an API Key by going to Settings -> API key management on your Opsgenie control panel, which will have an
address like `https://<your-org>.app.opsgenie.com/settings/api-key-management`, and click the "Add new API key" button.
For more information, see the
[Opsgenie API key management documentation](https://support.atlassian.com/opsgenie/docs/api-key-management/).

Once you have the key, you'll need to test it with a curl to verify that you are at least on a Standard plan with
OpsGenie:

```
curl -X GET 'https://api.opsgenie.com/v2/account' \
    --header "Authorization: GenieKey $API_KEY"
```

The result should be something similar to below:

```
{
    "data": {
        "name": "opsgenie",
        "plan": {
            "maxUserCount": 1500,
            "name": "Enterprise",
     ...
}
```

If you see `Free` or `Essentials` in the plan, then you won't be able to use this component. You can see more details
here: [OpsGenie pricing/features](https://www.atlassian.com/software/opsgenie/pricing#)

#### Getting Started

**Stack Level**: Global

Here's an example snippet for how to use this component.

This component should only be applied once as the resources it creates are regional, but it works with integrations.
This is typically done via the auto or corp stack (e.g. `gbl-auto.yaml`).

```yaml
# 9-5 Mon-Fri
business_hours: &business_hours
  type: "weekday-and-time-of-day"
  restrictions:
    - start_hour: 9
      start_min: 00
      start_day: "monday"
      end_hour: 17
      end_min: 00
      end_day: "friday"

# 9-5 Every Day
waking_hours: &waking_hours
  type: "time-of-day"
  restrictions:
    - start_hour: 9
      start_min: 00
      end_hour: 17
      end_min: 00

# This is a partial incident mapping, we use this as a base to add P1 & P2 below. This is not a complete mapping as there is no P0
priority_level_to_incident: &priority_level_to_incident
  enabled: true
  type: incident
  priority: P1
  order: 1
  notify: # if omitted, this will default to the default schedule
    type: schedule
    name: default
  criteria:
    type: "match-all-conditions"
    conditions:
      - field: priority
        operation: equals
        expected_value: P0

p1: &p1_is_incident
  <<: *priority_level_to_incident
  priority: P1
  criteria:
    type: "match-all-conditions"
    conditions:
      - field: priority
        operation: equals
        expected_value: P1

p2: &p2_is_incident
  <<: *priority_level_to_incident
  priority: P2
  criteria:
    type: "match-all-conditions"
    conditions:
      - field: priority
        operation: equals
        expected_value: P2

components:
  terraform:
    # defaults
    opsgenie-team-defaults:
      metadata:
        type: abstract
        component: opsgenie-team

      vars:
        schedules:
          london_schedule:
            enabled: false
            description: "London Schedule"
            timezone: "Europe/London"

        # Routing Rules determine how alerts are routed to the team,
        # this includes priority changes, incident mappings, and schedules.
        routing_rules:
          london_schedule:
            enabled: false
            type: alert
            # https://support.atlassian.com/opsgenie/docs/supported-timezone-ids/
            timezone: Europe/London
            notify:
              type: schedule # could be escalation, could be none
              name: london_schedule
            time_restriction: *waking_hours
            criteria:
              type: "match-all-conditions"
              conditions:
                - field: priority
                  operation: greater-than
                  expected_value: P2

          # Since Incidents require a service, we create a rule for every `routing_rule` type `incident` for every service on the team.
          # This is done behind the scenes by the `opsgenie-team` component.
          # These rules below map P1 & P2 to incidents, using yaml anchors from above.
          p1: *p1_is_incident
          p2: *p2_is_incident

    # New team
    opsgenie-team-sre:
      metadata:
        type: real
        component: opsgenie-team
        inherits:
          - opsgenie-team-defaults
      vars:
        enabled: true
        name: sre

        # These members will be added with an opsgenie_user
        # To clickops members, set this key to an empty list `[]`
        members:
          - user: user@example.com
            role: owner

        escalations:
          otherteam_escalation:
            enabled: true
            name: otherteam_escalation
            description: Other team escalation
            rules:
              condition: if-not-acked
              notify_type: default
              delay: 60
              recipients:
                - type: team
                  name: otherteam

          yaep_escalation:
            enabled: true
            name: yaep_escalation
            description: Yet another escalation policy
            rules:
              condition: if-not-acked
              notify_type: default
              delay: 90
              recipients:
                - type: user
                  name: user@example.com

          schedule_escalation:
            enabled: true
            name: schedule_escalation
            description: Schedule escalation policy
            rules:
              condition: if-not-acked
              notify_type: default
              delay: 30
              recipients:
                - type: schedule
                  name: secondary_on_call
```

The API keys relating to the Opsgenie Integrations are stored in SSM Parameter Store and can be accessed via chamber.

```
AWS_PROFILE=foo chamber list opsgenie-team/<team>
```

### ClickOps Work

- After deploying the opsgenie-team component the created team will have a schedule named after the team. This is
  purposely left to be clickOps’d so the UI can be used to set who is on call, as that is the usual way (not through
  code). Additionally, we do not want a re-apply of the Terraform to delete or shuffle who is planned to be on call,
  thus we left who is on-call on a schedule out of the component.

## Known Issues

### Different API Endpoints in Use

The problem is there are 3 different api endpoints in use

- `/webapp` - the most robust - only exposed to the UI (that we've seen)
- `/v2/` - robust with some differences from `webapp`
- `/v1/` - the oldest and furthest from the live UI.

### Cannot create users

This module does not create users. Users must have already been created to be added to a team.

### Cannot Add dependent Services

- Api Currently doesn't support Multiple ServiceIds for incident Rules

### Cannot Add Stakeholders

- Track the issue: https://github.com/opsgenie/terraform-provider-opsgenie/issues/278

### No Resource to create Slack Integration

- Track the issue: https://github.com/DataDog/terraform-provider-datadog/issues/67

### Out of Date Terraform Docs

Another Problem is the terraform docs are not always up to date with the provider code.

The OpsGenie Provider uses a mix of `/v1` and `/v2`. This means there are many things you can only do from the UI.

Listed below in no particular order

- Incident Routing cannot add dependent services - in `v1` and `v2` a `service_incident_rule` object has `serviceId` as
  type string, in webapp this becomes `serviceIds` of type `list(string)`
- Opsgenie Provider appears to be inconsistent with how it uses `time_restriction`:
  - `restrictions` for type `weekday-and-time-of-day`
  - `restriction` for type `time-of-day`

Unfortunately none of this is in the terraform docs, and was found via errors and digging through source code.

Track the issue: https://github.com/opsgenie/terraform-provider-opsgenie/issues/282

### GMT Style Timezones

We recommend to use the human readable timezone such as `Europe/London`.

- Setting a schedule to a GMT-style timezone with offsets can cause inconsistent plans.

  Setting the timezone to `Etc/GMT+1` instead of `Europe/London`, will lead to permadrift as OpsGenie converts the GMT
  offsets to regional timezones at deploy-time. In the previous deploy, the GMT style get converted to
  `Atlantic/Cape_Verde`.

  ```hcl
  # module.routing["london_schedule"].module.team_routing_rule[0].opsgenie_team_routing_rule.this[0] will be updated in-place
  ~ resource "opsgenie_team_routing_rule" "this" {
          id         = "4b4c4454-8ccf-41a9-b856-02bec6419ba7"
          name       = "london_schedule"
      ~ timezone   = "Atlantic/Cape_Verde" -> "Etc/GMT+1"
          # (2 unchanged attributes hidden)
  ```

  Some GMT styles will not cause a timezone change on subsequent applies such as `Etc/GMT+8` for `Asia/Taipei`.

- If the calendar date has crossed daylight savings time, the `Etc/GMT+` GMT style will need to be updated to reflect
  the correct timezone.

Track the issue: https://github.com/opsgenie/terraform-provider-opsgenie/issues/258

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.3.0 |
| <a name="requirement_opsgenie"></a> [opsgenie](#requirement\_opsgenie) | >= 0.6.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.3.0 |
| <a name="provider_opsgenie"></a> [opsgenie](#provider\_opsgenie) | >= 0.6.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_configuration"></a> [datadog\_configuration](#module\_datadog\_configuration) | ../datadog-configuration/modules/datadog_keys | n/a |
| <a name="module_escalation"></a> [escalation](#module\_escalation) | ./modules/escalation | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_integration"></a> [integration](#module\_integration) | ./modules/integration | n/a |
| <a name="module_members_merge"></a> [members\_merge](#module\_members\_merge) | cloudposse/config/yaml//modules/deepmerge | 1.0.2 |
| <a name="module_routing"></a> [routing](#module\_routing) | ./modules/routing | n/a |
| <a name="module_schedule"></a> [schedule](#module\_schedule) | cloudposse/incident-management/opsgenie//modules/schedule | 0.16.0 |
| <a name="module_service"></a> [service](#module\_service) | cloudposse/incident-management/opsgenie//modules/service | 0.16.0 |
| <a name="module_team"></a> [team](#module\_team) | cloudposse/incident-management/opsgenie//modules/team | 0.16.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [datadog_integration_opsgenie_service_object.fake_service_name](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_opsgenie_service_object) | resource |
| [aws_ssm_parameter.opsgenie_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.opsgenie_team_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [opsgenie_team.existing](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/team) | data source |
| [opsgenie_user.team_members](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_only_integrations_enabled"></a> [create\_only\_integrations\_enabled](#input\_create\_only\_integrations\_enabled) | Whether to reuse all existing resources and only create new integrations | `bool` | `false` | no |
| <a name="input_datadog_integration_enabled"></a> [datadog\_integration\_enabled](#input\_datadog\_integration\_enabled) | Whether to enable Datadog integration with opsgenie (datadog side) | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_escalations"></a> [escalations](#input\_escalations) | Escalations to configure and create for the team. | `map(any)` | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | API Integrations for the team. If not specified, `datadog` is assumed. | `map(any)` | `{}` | no |
| <a name="input_integrations_enabled"></a> [integrations\_enabled](#input\_integrations\_enabled) | Whether to enable the integrations submodule or not | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | AWS KMS key used for writing to SSM | `string` | `"alias/aws/ssm"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_members"></a> [members](#input\_members) | Members as objects with their role within the team. | `set(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_routing_rules"></a> [routing\_rules](#input\_routing\_rules) | Routing Rules for the team | `any` | `null` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Schedules to create for the team | `map(any)` | `{}` | no |
| <a name="input_services"></a> [services](#input\_services) | Services to create and register to the team. | `map(any)` | `{}` | no |
| <a name="input_ssm_parameter_name_format"></a> [ssm\_parameter\_name\_format](#input\_ssm\_parameter\_name\_format) | SSM parameter name format | `string` | `"/%s/%s"` | no |
| <a name="input_ssm_path"></a> [ssm\_path](#input\_ssm\_path) | SSM path | `string` | `"opsgenie"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Current OpsGenie Team Name | `string` | `null` | no |
| <a name="input_team_naming_format"></a> [team\_naming\_format](#input\_team\_naming\_format) | OpsGenie Team Naming Format | `string` | `"%s_%s"` | no |
| <a name="input_team_options"></a> [team\_options](#input\_team\_options) | Configure the team options.<br>See `opsgenie_team` Terraform resource [documentation](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/team#argument-reference) for more details. | <pre>object({<br>    description              = optional(string)<br>    ignore_members           = optional(bool, false)<br>    delete_default_resources = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_escalation"></a> [escalation](#output\_escalation) | Escalation rules created |
| <a name="output_integration"></a> [integration](#output\_integration) | Integrations created |
| <a name="output_routing"></a> [routing](#output\_routing) | Routing rules created |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | Team ID |
| <a name="output_team_members"></a> [team\_members](#output\_team\_members) | Team members |
| <a name="output_team_name"></a> [team\_name](#output\_team\_name) | Team Name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Related How-to Guides

[See OpsGenie in the Reference Architecture](https://docs.cloudposse.com/layers/alerting/opsgenie/)

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/opsgenie-team) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
