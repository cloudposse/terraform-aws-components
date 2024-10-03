---
tags:
  - component/philips-labs-github-runners
  - layer/github
  - provider/aws
---

# Component: `philips-labs-github-runners`

This component is responsible for provisioning the surrounding infrastructure for the github runners.

## Prerequisites

- Github App installed on the organization
  - For more details see
    [Philips Lab's Setting up a Github App](https://github.com/philips-labs/terraform-aws-github-runner/tree/main#setup-github-app-part-1)
  - Ensure you create a **PRIVATE KEY** and store it in SSM, **NOT** to be confused with a **Client Secret**. Private
    Keys are created in the GitHub App Configuration and scrolling to the bottom.
- Github App ID and private key stored in SSM under `/pl-github-runners/id` (or the value of
  `var.github_app_id_ssm_path`)
- Github App Private Key stored in SSM (base64 encoded) under `/pl-github-runners/key` (or the value of
  `var.github_app_key_ssm_path`)

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    philips-labs-github-runners:
      vars:
        enabled: true
```

The following will create

- An API Gateway
- Lambdas
- SQS Queue
- EC2 Launch Template instances

The API Gateway is registered as a webhook within the GitHub app. Which scales up or down, via lambdas, the EC2 Launch
Template by the number of messages in the SQS queue.

![Architecture](https://github.com/philips-labs/terraform-aws-github-runner/blob/main/docs/component-overview.svg)

## Modules

### `webhook-github-app`

This is a fork of https://github.com/philips-labs/terraform-aws-github-runner/tree/main/modules/webhook-github-app.

We customized it until this PR is resolved as it does not update the github app webhook until this is merged.

- https://github.com/philips-labs/terraform-aws-github-runner/pull/3625

This module also requires an environment variable

- `GH_TOKEN` - a github token be set

This module also requires the `gh` cli to be installed. Your Dockerfile can be updated to include the following to
install it:

```dockerfile
ARG GH_CLI_VERSION=2.39.1
# ...
ARG GH_CLI_VERSION
RUN apt-get update && apt-get install -y --allow-downgrades \
    gh="${GH_CLI_VERSION}-*"
```

By default, we leave this disabled, as it requires a github token to be set. You can enable it by setting
`var.enable_update_github_app_webhook` to `true`. When enabled, it will update the github app webhook to point to the
API Gateway. This can occur if the API Gateway is deleted and recreated.

When disabled, you will need to manually update the github app webhook to point to the API Gateway. This is output by
the component, and available via the `webhook` output under `endpoint`.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_runner"></a> [github\_runner](#module\_github\_runner) | philips-labs/github-runner/aws | 5.4.2 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_module_artifact"></a> [module\_artifact](#module\_module\_artifact) | cloudposse/module-artifact/external | 0.8.0 |
| <a name="module_store_read"></a> [store\_read](#module\_store\_read) | cloudposse/ssm-parameter-store/aws | 0.11.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_webhook_github_app"></a> [webhook\_github\_app](#module\_webhook\_github\_app) | philips-labs/github-runner/aws//modules/webhook-github-app | 5.4.2 |

## Resources

| Name | Type |
|------|------|
| [random_id.webhook_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_service_linked_role_spot"></a> [create\_service\_linked\_role\_spot](#input\_create\_service\_linked\_role\_spot) | (optional) create the service linked role for spot instances that is required by the scale-up lambda. | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enable_update_github_app_webhook"></a> [enable\_update\_github\_app\_webhook](#input\_enable\_update\_github\_app\_webhook) | Enable updating the github app webhook | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_app_id_ssm_path"></a> [github\_app\_id\_ssm\_path](#input\_github\_app\_id\_ssm\_path) | Path to the github app id in SSM | `string` | `"/pl-github-runners/id"` | no |
| <a name="input_github_app_key_ssm_path"></a> [github\_app\_key\_ssm\_path](#input\_github\_app\_key\_ssm\_path) | Path to the github key in SSM | `string` | `"/pl-github-runners/key"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_instance_target_capacity_type"></a> [instance\_target\_capacity\_type](#input\_instance\_target\_capacity\_type) | Default lifecycle used for runner instances, can be either `spot` or `on-demand`. | `string` | `"spot"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_release_version"></a> [release\_version](#input\_release\_version) | Version of the application | `string` | `"v5.4.0"` | no |
| <a name="input_runner_extra_labels"></a> [runner\_extra\_labels](#input\_runner\_extra\_labels) | Extra (custom) labels for the runners (GitHub). Labels checks on the webhook can be enforced by setting `enable_workflow_job_labels_check`. GitHub read-only labels should not be provided. | `list(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_scale_up_reserved_concurrent_executions"></a> [scale\_up\_reserved\_concurrent\_executions](#input\_scale\_up\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. | `number` | `-1` | no |
| <a name="input_ssm_paths"></a> [ssm\_paths](#input\_ssm\_paths) | The root path used in SSM to store configuration and secrets. | <pre>object({<br>    root       = optional(string, "github-action-runners")<br>    app        = optional(string, "app")<br>    runners    = optional(string, "runners")<br>    use_prefix = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_runners"></a> [github\_runners](#output\_github\_runners) | Information about the GitHub runners. |
| <a name="output_queues"></a> [queues](#output\_queues) | Information about the GitHub runner queues. Such as `build_queue_arn` the ARN of the SQS queue to use for the build queue. |
| <a name="output_ssm_parameters"></a> [ssm\_parameters](#output\_ssm\_parameters) | Information about the SSM parameters to use to register the runner. |
| <a name="output_webhook"></a> [webhook](#output\_webhook) | Information about the webhook to use to register the runner. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/ecs) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
