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


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3.0), version: >= 1.3.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0
- [`datadog`](https://registry.terraform.io/modules/datadog/>= 3.3.0), version: >= 3.3.0
- [`opsgenie`](https://registry.terraform.io/modules/opsgenie/>= 0.6.7), version: >= 0.6.7

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0
- `datadog`, version: >= 3.3.0
- `opsgenie`, version: >= 0.6.7

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`datadog_configuration` | latest | [`../datadog-configuration/modules/datadog_keys`](https://registry.terraform.io/modules/../datadog-configuration/modules/datadog_keys/) | n/a
`escalation` | latest | [`./modules/escalation`](https://registry.terraform.io/modules/./modules/escalation/) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`integration` | latest | [`./modules/integration`](https://registry.terraform.io/modules/./modules/integration/) | n/a
`members_merge` | 1.0.2 | [`cloudposse/config/yaml//modules/deepmerge`](https://registry.terraform.io/modules/cloudposse/config/yaml/modules/deepmerge/1.0.2) | n/a
`routing` | latest | [`./modules/routing`](https://registry.terraform.io/modules/./modules/routing/) | n/a
`schedule` | 0.16.0 | [`cloudposse/incident-management/opsgenie//modules/schedule`](https://registry.terraform.io/modules/cloudposse/incident-management/opsgenie/modules/schedule/0.16.0) | n/a
`service` | 0.16.0 | [`cloudposse/incident-management/opsgenie//modules/service`](https://registry.terraform.io/modules/cloudposse/incident-management/opsgenie/modules/service/0.16.0) | n/a
`team` | 0.16.0 | [`cloudposse/incident-management/opsgenie//modules/team`](https://registry.terraform.io/modules/cloudposse/incident-management/opsgenie/modules/team/0.16.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`datadog_integration_opsgenie_service_object.fake_service_name`](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_opsgenie_service_object) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.opsgenie_api_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.opsgenie_team_api_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`opsgenie_team.existing`](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/team) (data source)
  - [`opsgenie_user.team_members`](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/user) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
    This is for some rare cases where resources want additional configuration of tags<br/>
    and therefore take a list of maps with tag key, value, and additional configuration.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
    in the order they appear in the list. New attributes are appended to the<br/>
    end of the list. The elements of the list are joined by the `delimiter`<br/>
    and treated as a single ID element.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `[]`
  </dd>
  <dt>`context` (`any`) <i>optional</i></dt>
  <dd>
    Single object for setting entire context at once.<br/>
    See description of individual variables for details.<br/>
    Leave string and numeric variables as `null` to use default value.<br/>
    Individual variable settings (non-null) override settings in context object,<br/>
    except for attributes, tags, and additional_tag_map, which are merged.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** 
    ```hcl
    {
      "additional_tag_map": {},
      "attributes": [],
      "delimiter": null,
      "descriptor_formats": {},
      "enabled": true,
      "environment": null,
      "id_length_limit": null,
      "label_key_case": null,
      "label_order": [],
      "label_value_case": null,
      "labels_as_tags": [
        "unset"
      ],
      "name": null,
      "namespace": null,
      "regex_replace_chars": null,
      "stage": null,
      "tags": {},
      "tenant": null
    }
    ```
    
  </dd>
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between ID elements.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`descriptor_formats` (`any`) <i>optional</i></dt>
  <dd>
    Describe additional descriptors to be output in the `descriptors` output map.<br/>
    Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
    `{<br/>
       format = string<br/>
       labels = list(string)<br/>
    }`<br/>
    (Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
    `format` is a Terraform format string to be passed to the `format()` function.<br/>
    `labels` is a list of labels, in order, to pass to `format()` function.<br/>
    Label values will be normalized before being passed to `format()` so they will be<br/>
    identical to how they appear in `id`.<br/>
    Default is `{}` (`descriptors` output will be empty).<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** `{}`
  </dd>
  <dt>`enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to prevent the module from creating any resources<br/>
    **Required:** No<br/>
    **Type:** `bool`
    **Default value:** `null`
  </dd>
  <dt>`environment` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for keep the existing setting, which defaults to `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
    Does not affect keys of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The order in which the labels (ID elements) appear in the `id`.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of ID elements (labels) as included in `id`,<br/>
    set as tag values, and output by this module individually.<br/>
    Does not affect values of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`labels_as_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    Set of labels (ID elements) to include as tags in the `tags` output.<br/>
    Default is to include all labels.<br/>
    Tags with empty values will not be included in the `tags` output.<br/>
    Set to `[]` to suppress all generated tags.<br/>
    **Notes:**<br/>
      The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
      changed in later chained modules. Attempts to change it will be silently ignored.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `set(string)`
    **Default value:** 
    ```hcl
    [
      "default"
    ]
    ```
    
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
    This is the only ID element not also included as a `tag`.<br/>
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Terraform regular expression (regex) string.<br/>
    Characters matching the regex will be removed from the ID elements.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
    Neither the tag keys nor the tag values will be modified by this module.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`tenant` (`string`) <i>optional</i></dt>
  <dd>
    ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
</dl>

### Required Inputs

<dl>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`create_only_integrations_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to reuse all existing resources and only create new integrations<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`datadog_integration_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable Datadog integration with opsgenie (datadog side)<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`escalations` (`map(any)`) <i>optional</i></dt>
  <dd>
    Escalations to configure and create for the team. <br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`integrations` (`map(any)`) <i>optional</i></dt>
  <dd>
    API Integrations for the team. If not specified, `datadog` is assumed.<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`integrations_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable the integrations submodule or not<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`kms_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    AWS KMS key used for writing to SSM<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"alias/aws/ssm"`
  </dd>
  <dt>`members` (`set(any)`) <i>optional</i></dt>
  <dd>
    Members as objects with their role within the team.<br/>
    <br/>
    **Type:** `set(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`routing_rules` (`any`) <i>optional</i></dt>
  <dd>
    Routing Rules for the team<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`schedules` (`map(any)`) <i>optional</i></dt>
  <dd>
    Schedules to create for the team<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`services` (`map(any)`) <i>optional</i></dt>
  <dd>
    Services to create and register to the team.<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`ssm_parameter_name_format` (`string`) <i>optional</i></dt>
  <dd>
    SSM parameter name format<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/%s/%s"`
  </dd>
  <dt>`ssm_path` (`string`) <i>optional</i></dt>
  <dd>
    SSM path<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"opsgenie"`
  </dd>
  <dt>`team_name` (`string`) <i>optional</i></dt>
  <dd>
    Current OpsGenie Team Name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`team_naming_format` (`string`) <i>optional</i></dt>
  <dd>
    OpsGenie Team Naming Format<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"%s_%s"`
  </dd>
  <dt>`team_options` <i>optional</i></dt>
  <dd>
    Configure the team options.<br/>
    See `opsgenie_team` Terraform resource [documentation](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/team#argument-reference) for more details.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    description              = optional(string)
    ignore_members           = optional(bool, false)
    delete_default_resources = optional(bool, false)
  })
    ```
    
    <br/>
    **Default value:** `{}`
  </dd></dl>


### Outputs

<dl>
  <dt>`escalation`</dt>
  <dd>
    Escalation rules created<br/>
  </dd>
  <dt>`integration`</dt>
  <dd>
    Integrations created<br/>
  </dd>
  <dt>`routing`</dt>
  <dd>
    Routing rules created<br/>
  </dd>
  <dt>`team_id`</dt>
  <dd>
    Team ID<br/>
  </dd>
  <dt>`team_members`</dt>
  <dd>
    Team members<br/>
  </dd>
  <dt>`team_name`</dt>
  <dd>
    Team Name<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Related How-to Guides

- [How to Add Users to a Team in OpsGenie](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-add-users-to-a-team-in-opsgenie)
- [How to Pass Tags Along to Datadog](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-pass-tags-along-to-datadog)
- [How to Onboard a New Service with Datadog and OpsGenie](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-onboard-a-new-service-with-datadog-and-opsgenie)
- [How to Create Escalation Rules in OpsGenie](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-create-escalation-rules-in-opsgenie)
- [How to Setup Rotations in OpsGenie](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-setup-rotations-in-opsgenie)
- [How to Create New Teams in OpsGenie](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-create-new-teams-in-opsgenie)
- [How to Sign Up for OpsGenie?](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie/how-to-sign-up-for-opsgenie/)
- [How to Implement Incident Management with OpsGenie](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-implement-incident-management-with-opsgenie)

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/opsgenie-team) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
