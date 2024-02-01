# Component: `github-webhook`

This component provisions a GitHub webhook for a single GitHub repository.

You may want to use this component if you are provisioning webhooks for multiple ArgoCD deployment repositories across GitHub organizations.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component. This example pulls the value of the webhook from `remote-state`

```yaml
components:
  terraform:
    webhook/cloudposse/argocd:
      metadata:
        component: github-webhook
      vars:
        github_organization: cloudposse
        github_repository: argocd-deploy-non-prod
        webhook_url: "https://argocd.ue2.dev.plat.cloudposse.org/api/webhook"

        remote_state_github_webhook_enabled: true # default value added for visibility
        remote_state_component_name: eks/argocd
```

### SSM Stored Value Example

Here's an example snippet for how to use this component with a value stored in SSM

```yaml
components:
  terraform:
    webhook/cloudposse/argocd:
      metadata:
        component: github-webhook
      vars:
        github_organization: cloudposse
        github_repository: argocd-deploy-non-prod
        webhook_url: "https://argocd.ue2.dev.plat.cloudposse.org/api/webhook"

        remote_state_github_webhook_enabled: false
        ssm_github_webhook_enabled: true
        ssm_github_webhook: "/argocd/github/webhook"
```

### Input Value Example

Here's an example snippet for how to use this component with a value stored in Terraform variables.

```yaml
components:
  terraform:
    webhook/cloudposse/argocd:
      metadata:
        component: github-webhook
      vars:
        github_organization: cloudposse
        github_repository: argocd-deploy-non-prod
        webhook_url: "https://argocd.ue2.dev.plat.cloudposse.org/api/webhook"

        remote_state_github_webhook_enabled: false
        ssm_github_webhook_enabled: false
        webhook_github_secret: "abcdefg"
```


### ArgoCD Webhooks

For usage with the `eks/argocd` component, see [Creating Webhooks with `github-webhook`](https://github.com/cloudposse/terraform-aws-components/blob/main/modules/eks/argocd/README.md#creating-webhooks-with-github-webhook) in that component's README.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_github"></a> [github](#provider\_github) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_source"></a> [source](#module\_source) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [github_repository_webhook.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [aws_ssm_parameter.github_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/` | `string` | `null` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The name of the GitHub Organization where the repository lives | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | The name of the GitHub repository where the webhook will be created | `string` | n/a | yes |
| <a name="input_github_token_override"></a> [github\_token\_override](#input\_github\_token\_override) | Use the value of this variable as the GitHub token instead of reading it from SSM | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_remote_state_component_name"></a> [remote\_state\_component\_name](#input\_remote\_state\_component\_name) | If fetching the Github Webhook value from remote-state, set this to the source compoennt name. For example, `eks/argocd`. | `string` | `""` | no |
| <a name="input_remote_state_github_webhook_enabled"></a> [remote\_state\_github\_webhook\_enabled](#input\_remote\_state\_github\_webhook\_enabled) | If `true`, pull the GitHub Webhook value from remote-state | `bool` | `true` | no |
| <a name="input_ssm_github_api_key"></a> [ssm\_github\_api\_key](#input\_ssm\_github\_api\_key) | SSM path to the GitHub API key | `string` | `"/argocd/github/api_key"` | no |
| <a name="input_ssm_github_webhook"></a> [ssm\_github\_webhook](#input\_ssm\_github\_webhook) | Format string of the SSM parameter path where the webhook will be pulled from. Only used if `var.webhook_github_secret` is not given. | `string` | `"/github/webhook"` | no |
| <a name="input_ssm_github_webhook_enabled"></a> [ssm\_github\_webhook\_enabled](#input\_ssm\_github\_webhook\_enabled) | If `true`, pull the GitHub Webhook value from AWS SSM Parameter Store using `var.ssm_github_webhook` | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_webhook_github_secret"></a> [webhook\_github\_secret](#input\_webhook\_github\_secret) | The value to use as the GitHub webhook secret. Set both `var.ssm_github_webhook_enabled` and `var.remote_state_github_webhook_enabled` to `false` in order to use this value | `string` | `""` | no |
| <a name="input_webhook_url"></a> [webhook\_url](#input\_webhook\_url) | The URL for the webhook | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components) - Cloud Posse's upstream components

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
