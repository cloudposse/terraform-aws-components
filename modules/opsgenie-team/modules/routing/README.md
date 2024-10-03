## Routing

This module creates team routing rules, these are the initial rules that are applied to an alert to determine who gets
notified. This module also creates incident service rules, which determine if an alert is considered a service incident
or not.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_opsgenie"></a> [opsgenie](#requirement\_opsgenie) | >= 0.6.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opsgenie"></a> [opsgenie](#provider\_opsgenie) | >= 0.6.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service_incident_rule"></a> [service\_incident\_rule](#module\_service\_incident\_rule) | cloudposse/incident-management/opsgenie//modules/service_incident_rule | 0.16.0 |
| <a name="module_serviceless_incident_rule"></a> [serviceless\_incident\_rule](#module\_serviceless\_incident\_rule) | cloudposse/incident-management/opsgenie//modules/service_incident_rule | 0.16.0 |
| <a name="module_team_routing_rule"></a> [team\_routing\_rule](#module\_team\_routing\_rule) | cloudposse/incident-management/opsgenie//modules/team_routing_rule | 0.16.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [opsgenie_schedule.notification_schedule](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/schedule) | data source |
| [opsgenie_service.incident_service](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/service) | data source |
| [opsgenie_team.default](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/data-sources/team) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_criteria"></a> [criteria](#input\_criteria) | Criteria of the Routing Rule, rules to match or not | <pre>object({<br>    type       = string,<br>    conditions = any<br>  })</pre> | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_incident_properties"></a> [incident\_properties](#input\_incident\_properties) | Properties to override on the incident routing rule | `map(any)` | n/a | yes |
| <a name="input_is_default"></a> [is\_default](#input\_is\_default) | Set this alerting route as the default route | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_notify"></a> [notify](#input\_notify) | Notification of team alerting rule | `map(any)` | n/a | yes |
| <a name="input_order"></a> [order](#input\_order) | Order of the alerting rule | `number` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | Priority level of custom Incidents | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_services"></a> [services](#input\_services) | Team services to associate with incident routing rules | `map(any)` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Current OpsGenie Team Name | `string` | `null` | no |
| <a name="input_team_naming_format"></a> [team\_naming\_format](#input\_team\_naming\_format) | OpsGenie Team Naming Format | `string` | `"%s_%s"` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_time_restriction"></a> [time\_restriction](#input\_time\_restriction) | Time restriction of alert routing rule | `any` | `null` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for this alerting route | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of Routing Rule Alert or Incident | `string` | `"alert"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_incident_rule"></a> [service\_incident\_rule](#output\_service\_incident\_rule) | Service incident rules for incidents |
| <a name="output_team_routing_rule"></a> [team\_routing\_rule](#output\_team\_routing\_rule) | Team routing rules for alerts |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
