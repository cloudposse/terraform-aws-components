# Component: `datadog-synthetics`

This component provides the ability to implement
[Datadog synthetic tests](https://docs.datadoghq.com/synthetics/guide/).

Synthetic tests allow you to observe how your systems and applications are performing using simulated requests and
actions from the AWS managed locations around the globe, and to monitor internal endpoints from
[Private Locations](https://docs.datadoghq.com/synthetics/private_locations).

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component:

### Stack Configuration

```yaml
components:
  terraform:
    datadog-synthetics:
      metadata:
        component: "datadog-synthetics"
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: "datadog-synthetics"
        locations:
          - "all"
        # List of paths to Datadog synthetic test configurations
        synthetics_paths:
          - "catalog/synthetics/examples/*.yaml"
        synthetics_private_location_component_name: "datadog-synthetics-private-location"
        private_location_test_enabled: true
```

### Synthetics Configuration Examples

Below are examples of Datadog browser and API synthetic tests.

The synthetic tests are defined in YAML using either the
[Datadog Terraform provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/synthetics_test)
schema or the [Datadog Synthetics API](https://docs.datadoghq.com/api/latest/synthetics) schema. See the
`terraform-datadog-platform` Terraform module
[README](https://github.com/cloudposse/terraform-datadog-platform/blob/main/modules/synthetics/README.md) for more
details. We recommend using the API schema so you can more create and edit tests using the Datadog web API and then
import them into this module by downloading the test using the Datadog REST API. (See the Datadog API documentation for
the appropriate `curl` commands to use.)

```yaml
# API schema
my-browser-test:
  name: My Browser Test
  status: live
  type: browser
  config:
    request:
      method: GET
      headers: {}
      url: https://example.com/login
    setCookie: |-
      DatadogTest=true
  message: "My Browser Test Failed"
  options:
    device_ids:
      - chrome.laptop_large
      - edge.tablet
      - firefox.mobile_small
    ignoreServerCertificateError: false
    disableCors: false
    disableCsp: false
    noScreenshot: false
    tick_every: 86400
    min_failure_duration: 0
    min_location_failed: 1
    retry:
      count: 0
      interval: 300
    monitor_options:
      renotify_interval: 0
    ci:
      executionRule: non_blocking
    rumSettings:
      isEnabled: false
    enableProfiling: false
    enableSecurityTesting: false
  locations:
    - aws:us-east-1
    - aws:us-west-2

# Terraform schema
my-api-test:
  name: "API Test"
  message: "API Test Failed"
  type: api
  subtype: http
  tags:
    - "managed-by:Terraform"
  status: "live"
  request_definition:
    url: "CHANGEME"
    method: GET
  request_headers:
    Accept-Charset: "utf-8, iso-8859-1;q=0.5"
    Accept: "text/json"
  options_list:
    tick_every: 1800
    no_screenshot: false
    follow_redirects: true
    retry:
      count: 2
      interval: 10
    monitor_options:
      renotify_interval: 300
  assertion:
    - type: statusCode
      operator: is
      target: "200"
    - type: body
      operator: validatesJSONPath
      targetjsonpath:
        operator: is
        targetvalue: true
        jsonpath: foo.bar
```

These configuration examples are defined in the YAML files in the
[catalog/synthetics/examples](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/datadog-synthetics/catalog/synthetics/examples)
folder.

You can use different subfolders for your use-case. For example, you can have `dev` and `prod` subfolders to define
different synthetic tests for the `dev` and `prod` environments.

Then use the `synthetic_paths` variable to point the component to the synthetic test configuration files.

The configuration files are processed and transformed in the following order:

- The `datadog-synthetics` component loads the YAML configuration files from the filesystem paths specified by the
  `synthetics_paths` variable

- Then, in the
  [synthetics](https://github.com/cloudposse/terraform-datadog-platform/blob/master/modules/synthetics/main.tf) module,
  the YAML configuration files are merged and transformed from YAML into the
  [Datadog Terraform provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/synthetics_test)
  schema

- And finally, the Datadog Terraform provider uses the
  [Datadog Synthetics API](https://docs.datadoghq.com/api/latest/synthetics) specifications to call the Datadog API and
  provision the synthetic tests

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_configuration"></a> [datadog\_configuration](#module\_datadog\_configuration) | ../datadog-configuration/modules/datadog_keys | n/a |
| <a name="module_datadog_synthetics"></a> [datadog\_synthetics](#module\_datadog\_synthetics) | cloudposse/platform/datadog//modules/synthetics | 1.3.0 |
| <a name="module_datadog_synthetics_merge"></a> [datadog\_synthetics\_merge](#module\_datadog\_synthetics\_merge) | cloudposse/config/yaml//modules/deepmerge | 1.0.2 |
| <a name="module_datadog_synthetics_private_location"></a> [datadog\_synthetics\_private\_location](#module\_datadog\_synthetics\_private\_location) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_datadog_synthetics_yaml_config"></a> [datadog\_synthetics\_yaml\_config](#module\_datadog\_synthetics\_yaml\_config) | cloudposse/config/yaml | 1.0.2 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alert_tags"></a> [alert\_tags](#input\_alert\_tags) | List of alert tags to add to all alert messages, e.g. `["@opsgenie"]` or `["@devops", "@opsgenie"]` | `list(string)` | `null` | no |
| <a name="input_alert_tags_separator"></a> [alert\_tags\_separator](#input\_alert\_tags\_separator) | Separator for the alert tags. All strings from the `alert_tags` variable will be joined into one string using the separator and then added to the alert message | `string` | `"\n"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_config_parameters"></a> [config\_parameters](#input\_config\_parameters) | Map of parameter values to interpolate into Datadog Synthetic configurations | `map(any)` | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_context_tags"></a> [context\_tags](#input\_context\_tags) | List of context tags to add to each synthetic check | `set(string)` | <pre>[<br>  "namespace",<br>  "tenant",<br>  "environment",<br>  "stage"<br>]</pre> | no |
| <a name="input_context_tags_enabled"></a> [context\_tags\_enabled](#input\_context\_tags\_enabled) | Whether to add context tags to add to each synthetic check | `bool` | `true` | no |
| <a name="input_datadog_synthetics_globals"></a> [datadog\_synthetics\_globals](#input\_datadog\_synthetics\_globals) | Map of keys to add to every monitor | `any` | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_locations"></a> [locations](#input\_locations) | Array of locations used to run synthetic tests | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_private_location_test_enabled"></a> [private\_location\_test\_enabled](#input\_private\_location\_test\_enabled) | Use private locations or the public locations provided by datadog | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_synthetics_paths"></a> [synthetics\_paths](#input\_synthetics\_paths) | List of paths to Datadog synthetic test configurations | `list(string)` | n/a | yes |
| <a name="input_synthetics_private_location_component_name"></a> [synthetics\_private\_location\_component\_name](#input\_synthetics\_private\_location\_component\_name) | The name of the Datadog synthetics private location component | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datadog_synthetics_test_ids"></a> [datadog\_synthetics\_test\_ids](#output\_datadog\_synthetics\_test\_ids) | IDs of the created Datadog synthetic tests |
| <a name="output_datadog_synthetics_test_maps"></a> [datadog\_synthetics\_test\_maps](#output\_datadog\_synthetics\_test\_maps) | Map (name: id) of the created Datadog synthetic tests |
| <a name="output_datadog_synthetics_test_monitor_ids"></a> [datadog\_synthetics\_test\_monitor\_ids](#output\_datadog\_synthetics\_test\_monitor\_ids) | IDs of the monitors associated with the Datadog synthetics tests |
| <a name="output_datadog_synthetics_test_names"></a> [datadog\_synthetics\_test\_names](#output\_datadog\_synthetics\_test\_names) | Names of the created Datadog synthetic tests |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [Datadog Synthetics](https://docs.datadoghq.com/synthetics)
- [Getting Started with Synthetic Monitoring](https://docs.datadoghq.com/getting_started/synthetics)
- [Synthetic Monitoring Guides](https://docs.datadoghq.com/synthetics/guide)
- [Using Synthetic Test Monitors](https://docs.datadoghq.com/synthetics/guide/synthetic-test-monitors)
- [Create An API Test With The API](https://docs.datadoghq.com/synthetics/guide/create-api-test-with-the-api)
- [Manage Your Browser Tests Programmatically](https://docs.datadoghq.com/synthetics/guide/manage-browser-tests-through-the-api)
- [Browser Tests](https://docs.datadoghq.com/synthetics/browser_tests)
- [Synthetics API](https://docs.datadoghq.com/api/latest/synthetics)
- [Terraform resource `datadog_synthetics_test`](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/synthetics_test)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
