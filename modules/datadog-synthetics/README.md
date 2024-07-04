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


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |
| `datadog` | >= 3.3.0 |




### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`datadog_configuration` | latest | [`../datadog-configuration/modules/datadog_keys`](https://registry.terraform.io/modules/../datadog-configuration/modules/datadog_keys/) | n/a
`datadog_synthetics` | 1.3.0 | [`cloudposse/platform/datadog//modules/synthetics`](https://registry.terraform.io/modules/cloudposse/platform/datadog/modules/synthetics/1.3.0) | n/a
`datadog_synthetics_merge` | 1.0.2 | [`cloudposse/config/yaml//modules/deepmerge`](https://registry.terraform.io/modules/cloudposse/config/yaml/modules/deepmerge/1.0.2) | n/a
`datadog_synthetics_private_location` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`datadog_synthetics_yaml_config` | 1.0.2 | [`cloudposse/config/yaml`](https://registry.terraform.io/modules/cloudposse/config/yaml/1.0.2) | Convert all Datadog synthetics from YAML config to Terraform map
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a



---
### Required Variables
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `synthetics_paths` (`list(string)`) <i>required</i>


List of paths to Datadog synthetic test configurations<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



---
### Optional Variables
### `alert_tags` (`list(string)`) <i>optional</i>


List of alert tags to add to all alert messages, e.g. `["@opsgenie"]` or `["@devops", "@opsgenie"]`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `alert_tags_separator` (`string`) <i>optional</i>


Separator for the alert tags. All strings from the `alert_tags` variable will be joined into one string using the separator and then added to the alert message<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"\n"</code>
>   </dd>
> </dl>
>


### `config_parameters` (`map(any)`) <i>optional</i>


Map of parameter values to interpolate into Datadog Synthetic configurations<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(any)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `context_tags` (`set(string)`) <i>optional</i>


List of context tags to add to each synthetic check<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "namespace",
>
>      "tenant",
>
>      "environment",
>
>      "stage"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `context_tags_enabled` (`bool`) <i>optional</i>


Whether to add context tags to add to each synthetic check<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `datadog_synthetics_globals` (`any`) <i>optional</i>


Map of keys to add to every monitor<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `locations` (`list(string)`) <i>optional</i>


Array of locations used to run synthetic tests<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `private_location_test_enabled` (`bool`) <i>optional</i>


Use private locations or the public locations provided by datadog<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `synthetics_private_location_component_name` (`string`) <i>optional</i>


The name of the Datadog synthetics private location component<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



---
### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


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

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>

### Outputs

<dl>
  <dt><code>datadog_synthetics_test_ids</code></dt>
  <dd>
    IDs of the created Datadog synthetic tests<br/>

  </dd>
  <dt><code>datadog_synthetics_test_maps</code></dt>
  <dd>
    Map (name: id) of the created Datadog synthetic tests<br/>

  </dd>
  <dt><code>datadog_synthetics_test_monitor_ids</code></dt>
  <dd>
    IDs of the monitors associated with the Datadog synthetics tests<br/>

  </dd>
  <dt><code>datadog_synthetics_test_names</code></dt>
  <dd>
    Names of the created Datadog synthetic tests<br/>

  </dd>
</dl>
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
