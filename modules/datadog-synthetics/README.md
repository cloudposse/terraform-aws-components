# Component: `datadog-synthetics`

This component is responsible for provisioning Datadog synthetic tests. 

Synthetic tests allow you to observe how your systems and applications are performing using simulated requests and actions 
from the managed locations around the globe and to monitor internal endpoints from private locations.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    datadog-synthetics:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        secrets_store_type: SSM
        synthetics_paths:
          - "catalog/synthetics/defaults/*.yaml"
          - "catalog/synthetics/acme/*.yaml"
          - "catalog/synthetics/acme/sandbox/*.yaml"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_synthetics"></a> [datadog\_synthetics](#module\_datadog\_synthetics) | cloudposse/platform/datadog//modules/synthetics | 0.27.0 |
| <a name="module_datadog_synthetics_merge"></a> [datadog\_synthetics\_merge](#module\_datadog\_synthetics\_merge) | cloudposse/config/yaml//modules/deepmerge | 0.4.0 |
| <a name="module_datadog_synthetics_private_location"></a> [datadog\_synthetics\_private\_location](#module\_datadog\_synthetics\_private\_location) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.0 |
| <a name="module_datadog_synthetics_yaml_config"></a> [datadog\_synthetics\_yaml\_config](#module\_datadog\_synthetics\_yaml\_config) | cloudposse/config/yaml | 0.8.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles_datadog_secrets"></a> [iam\_roles\_datadog\_secrets](#module\_iam\_roles\_datadog\_secrets) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.datadog_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.datadog_app_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.datadog_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.datadog_app_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.datadog_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.datadog_app_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alert_tags"></a> [alert\_tags](#input\_alert\_tags) | List of alert tags to add to all alert messages, e.g. `["@opsgenie"]` or `["@devops", "@opsgenie"]` | `list(string)` | `null` | no |
| <a name="input_alert_tags_separator"></a> [alert\_tags\_separator](#input\_alert\_tags\_separator) | Separator for the alert tags. All strings from the `alert_tags` variable will be joined into one string using the separator and then added to the alert message | `string` | `"\n"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_config_parameters"></a> [config\_parameters](#input\_config\_parameters) | Map of parameters to Datadog monitor configurations | `map(any)` | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_context_tags"></a> [context\_tags](#input\_context\_tags) | List of context tags to add to each synthetic check | `set(string)` | <pre>[<br>  "namespace",<br>  "tenant",<br>  "environment",<br>  "stage"<br>]</pre> | no |
| <a name="input_context_tags_enabled"></a> [context\_tags\_enabled](#input\_context\_tags\_enabled) | Whether to add context tags to add to each synthetic check | `bool` | `true` | no |
| <a name="input_datadog_api_secret_key"></a> [datadog\_api\_secret\_key](#input\_datadog\_api\_secret\_key) | The key of the Datadog API secret | `string` | `"datadog/datadog_api_key"` | no |
| <a name="input_datadog_app_secret_key"></a> [datadog\_app\_secret\_key](#input\_datadog\_app\_secret\_key) | The key of the Datadog Application secret | `string` | `"datadog/datadog_app_key"` | no |
| <a name="input_datadog_secrets_source_store_account"></a> [datadog\_secrets\_source\_store\_account](#input\_datadog\_secrets\_source\_store\_account) | Account (stage) holding Secret Store for Datadog API and app keys. | `string` | `"auto"` | no |
| <a name="input_datadog_synthetics_globals"></a> [datadog\_synthetics\_globals](#input\_datadog\_synthetics\_globals) | Map of keys to add to every monitor | `any` | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_locations"></a> [locations](#input\_locations) | Array of locations used to run synthetic tests | `list(string)` | <pre>[<br>  "all"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_private_location_test_enabled"></a> [private\_location\_test\_enabled](#input\_private\_location\_test\_enabled) | Use private locations or the public locations provided by datadog | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_secrets_store_type"></a> [secrets\_store\_type](#input\_secrets\_store\_type) | Secret store type for Datadog API and app keys. Valid values: `SSM`, `ASM` | `string` | `"SSM"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_synthetics_paths"></a> [synthetics\_paths](#input\_synthetics\_paths) | List of paths to Datadog synthetic test configurations | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datadog_synthetics_test_ids"></a> [datadog\_synthetics\_test\_ids](#output\_datadog\_synthetics\_test\_ids) | IDs of the created Datadog synthetic tests |
| <a name="output_datadog_synthetics_test_monitor_ids"></a> [datadog\_synthetics\_test\_monitor\_ids](#output\_datadog\_synthetics\_test\_monitor\_ids) | IDs of the monitors associated with the Datadog synthetics tests |
| <a name="output_datadog_synthetics_test_names"></a> [datadog\_synthetics\_test\_names](#output\_datadog\_synthetics\_test\_names) | Names of the created Datadog synthetic tests |
| <a name="output_datadog_synthetics_tests"></a> [datadog\_synthetics\_tests](#output\_datadog\_synthetics\_tests) | The synthetic tests created in Datadog |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References

 - [Datadog-Synthetics](https://docs.datadoghq.com/synthetics)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
