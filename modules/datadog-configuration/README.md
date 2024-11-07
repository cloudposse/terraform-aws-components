---
tags:
  - component/datadog-configuration
  - layer/datadog
  - provider/datadog
  - provider/aws
---

# Component: `datadog-configuration`

This component is responsible for provisioning SSM or ASM entries for Datadog API keys.

It's required that the DataDog API and APP secret keys are available in the `var.datadog_secrets_source_store_account`
account in AWS SSM Parameter Store at the `/datadog/%v/datadog_app_key` paths (where `%v` are the corresponding account
names).

This component copies keys from the source account (e.g. `auto`) to the destination account where this is being
deployed. The purpose of using this formatted copying of keys handles a couple of problems.

1. The keys are needed in each account where datadog resources will be deployed.
1. The keys might need to be different per account or tenant, or any subset of accounts.
1. If the keys need to be rotated they can be rotated from a single management account.

This module also has a submodule which allows other resources to quickly use it to create a datadog provider.

See Datadog's [documentation about provisioning keys](https://docs.datadoghq.com/account_management/api-app-keys) for
more information.

## Usage

**Stack Level**: Global

> [!WARNING] This is subject to change from a **Global** to a **Regional** stack level. This is because we need the keys
> in each region where we deploy datadog resources - so that we don't need to configure extra AWS Providers (which would
> need to be dynamic - which we cannot do). This is a limitation of Terraform.

This component should be deployed to every account where you want to provision datadog resources. This is usually every
account except `root` and `identity`

Here's an example snippet for how to use this component. It's suggested to apply this component to all accounts which
you want to track AWS metrics with DataDog. In this example we use the key paths `/datadog/%v/datadog_api_key` and
`/datadog/%v/datadog_app_key` where `%v` is `default`, this can be changed through `datadog_app_secret_key` &
`datadog_api_secret_key` variables. The output Keys in the deployed account will be `/datadog/datadog_api_key` and
`/datadog/datadog_app_key`.

```yaml
components:
  terraform:
    datadog-configuration:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: datadog-configuration
        datadog_secrets_store_type: SSM
        datadog_secrets_source_store_account_stage: auto
        datadog_secrets_source_store_account_region: "us-east-2"
```

Here is a snippet of using the `datadog_keys` submodule:

```terraform
module "datadog_configuration" {
  source  = "../datadog-configuration/modules/datadog_keys"
  enabled = true
  context = module.this.context
}

provider "datadog" {
  api_key  = module.datadog_configuration.datadog_api_key
  app_key  = module.datadog_configuration.datadog_app_key
  api_url  = module.datadog_configuration.datadog_api_url
  validate = local.enabled
}
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.api_keys"></a> [aws.api\_keys](#provider\_aws.api\_keys) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles_datadog_secrets"></a> [iam\_roles\_datadog\_secrets](#module\_iam\_roles\_datadog\_secrets) | ../account-map/modules/iam-roles | n/a |
| <a name="module_store_write"></a> [store\_write](#module\_store\_write) | cloudposse/ssm-parameter-store/aws | 0.10.0 |
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
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_datadog_api_secret_key"></a> [datadog\_api\_secret\_key](#input\_datadog\_api\_secret\_key) | The name of the Datadog API secret | `string` | `"default"` | no |
| <a name="input_datadog_api_secret_key_source_pattern"></a> [datadog\_api\_secret\_key\_source\_pattern](#input\_datadog\_api\_secret\_key\_source\_pattern) | The format string (%v will be replaced by the var.datadog\_api\_secret\_key) for the key of the Datadog API secret in the source account | `string` | `"/datadog/%v/datadog_api_key"` | no |
| <a name="input_datadog_api_secret_key_target_pattern"></a> [datadog\_api\_secret\_key\_target\_pattern](#input\_datadog\_api\_secret\_key\_target\_pattern) | The format string (%v will be replaced by the var.datadog\_api\_secret\_key) for the key of the Datadog API secret in the target account | `string` | `"/datadog/datadog_api_key"` | no |
| <a name="input_datadog_app_secret_key"></a> [datadog\_app\_secret\_key](#input\_datadog\_app\_secret\_key) | The name of the Datadog APP secret | `string` | `"default"` | no |
| <a name="input_datadog_app_secret_key_source_pattern"></a> [datadog\_app\_secret\_key\_source\_pattern](#input\_datadog\_app\_secret\_key\_source\_pattern) | The format string (%v will be replaced by the var.datadog\_app\_secret\_key) for the key of the Datadog APP secret in the source account | `string` | `"/datadog/%v/datadog_app_key"` | no |
| <a name="input_datadog_app_secret_key_target_pattern"></a> [datadog\_app\_secret\_key\_target\_pattern](#input\_datadog\_app\_secret\_key\_target\_pattern) | The format string (%v will be replaced by the var.datadog\_api\_secret\_key) for the key of the Datadog APP secret in the target account | `string` | `"/datadog/datadog_app_key"` | no |
| <a name="input_datadog_secrets_source_store_account_region"></a> [datadog\_secrets\_source\_store\_account\_region](#input\_datadog\_secrets\_source\_store\_account\_region) | Region for holding Secret Store Datadog Keys, leave as null to use the same region as the stack | `string` | `null` | no |
| <a name="input_datadog_secrets_source_store_account_stage"></a> [datadog\_secrets\_source\_store\_account\_stage](#input\_datadog\_secrets\_source\_store\_account\_stage) | Stage holding Secret Store for Datadog API and app keys. | `string` | `"auto"` | no |
| <a name="input_datadog_secrets_source_store_account_tenant"></a> [datadog\_secrets\_source\_store\_account\_tenant](#input\_datadog\_secrets\_source\_store\_account\_tenant) | Tenant holding Secret Store for Datadog API and app keys. | `string` | `"core"` | no |
| <a name="input_datadog_secrets_store_type"></a> [datadog\_secrets\_store\_type](#input\_datadog\_secrets\_store\_type) | Secret Store type for Datadog API and app keys. Valid values: `SSM`, `ASM` | `string` | `"SSM"` | no |
| <a name="input_datadog_site_url"></a> [datadog\_site\_url](#input\_datadog\_site\_url) | The Datadog Site URL, https://docs.datadoghq.com/getting_started/site/ | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datadog_api_key_location"></a> [datadog\_api\_key\_location](#output\_datadog\_api\_key\_location) | The Datadog API key in the secrets store |
| <a name="output_datadog_api_url"></a> [datadog\_api\_url](#output\_datadog\_api\_url) | The URL of the Datadog API |
| <a name="output_datadog_app_key_location"></a> [datadog\_app\_key\_location](#output\_datadog\_app\_key\_location) | The Datadog APP key location in the secrets store |
| <a name="output_datadog_secrets_store_type"></a> [datadog\_secrets\_store\_type](#output\_datadog\_secrets\_store\_type) | The type of the secrets store to use for Datadog API and APP keys |
| <a name="output_datadog_site"></a> [datadog\_site](#output\_datadog\_site) | The Datadog site to use |
| <a name="output_region"></a> [region](#output\_region) | The region where the keys will be created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- Datadog's [documentation about provisioning keys](https://docs.datadoghq.com/account_management/api-app-keys)
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/datadog-configuration) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
