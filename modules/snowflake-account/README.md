---
tags:
  - component/snowflake-account
  - layer/unassigned
  - provider/aws
  - provider/snowflake
---

# Component: `snowflake-account`

This component sets up the requirements for all other Snowflake components, including creating the Terraform service
user. Before running this component, follow the manual, Click-Ops steps below to create a Snowflake subscription.

## Deployment Steps

1. Open the AWS Console for the given stack.
2. Go to AWS Marketplace Subscriptions.
3. Click "Manage Subscriptions", click "Discover products", type "Snowflake" in the search bar.
4. Select "Snowflake Data Cloud"
5. Click "Continue to Subscribe"

6. Fill out the information steps using the following as an example. Note, the provided email cannot use labels such as
   `mdev+sbx01@example.com`.

```
  First Name: John
  Last Name: Smith
  Email: aws@example.com
  Company: Example
  Country: United States
```

7. Select "Standard" and the current region. In this example, we chose "US East (Ohio)" which is the same as
   `us-east-1`.
8. Continue and wait for Sign Up to complete. Note the Snowflake account ID; you can find this in the newly accessible
   Snowflake console in the top right of the window.
9. Check for the Account Activation email. Note, this may be collected in a Slack notifications channel for easy access.
10. Follow the given link to create the Admin user with username `admin` and a strong password. Be sure to save that
    password somewhere secure.
11. Upload that password to AWS Parameter Store under `/snowflake/$ACCOUNT/users/admin/password`, where `ACCOUNT` is the
    value given during the subscription process. This password will only be used to create a private key, and all other
    authentication will be done with said key. Below is an example of how to do that with a
    [chamber](https://github.com/segmentio/chamber) command:

```
AWS_PROFILE=$NAMESPACE-$TENANT-gbl-sbx01-admin chamber write /snowflake/$ACCOUNT/users/admin/ admin $PASSWORD
```

11. Finally, use atmos to deploy this component:

```
atmos terraform deploy snowflake/account --stack $TENANT-use2-sbx01
```

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    snowflake-account:
      settings:
        spacelift:
          workspace_enabled: false
      vars:
        enabled: true
        snowflake_account: "AB12345"
        snowflake_account_region: "us-east-2"
        snowflake_user_email_format: "aws.dev+%s@example.com"
        tags:
          Team: data
          Service: snowflake
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.3 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 0.25 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.3 |
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 0.25 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account"></a> [account](#module\_account) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_introspection"></a> [introspection](#module\_introspection) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_account"></a> [snowflake\_account](#module\_snowflake\_account) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_role"></a> [snowflake\_role](#module\_snowflake\_role) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_warehouse"></a> [snowflake\_warehouse](#module\_snowflake\_warehouse) | cloudposse/label/null | 0.25.0 |
| <a name="module_ssm_parameters"></a> [ssm\_parameters](#module\_ssm\_parameters) | cloudposse/ssm-parameter-store/aws | 0.9.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 0.8.1 |

## Resources

| Name | Type |
|------|------|
| [random_password.terraform_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [snowflake_role.terraform](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/role) | resource |
| [snowflake_role_grants.grant_custom_roles](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/role_grants) | resource |
| [snowflake_role_grants.grant_system_roles](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/role_grants) | resource |
| [snowflake_user.terraform](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/user) | resource |
| [snowflake_warehouse.default](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/warehouse) | resource |
| [tls_private_key.terraform_user_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ssm_parameter.snowflake_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_warehouse_size"></a> [default\_warehouse\_size](#input\_default\_warehouse\_size) | The size for the default Snowflake Warehouse | `string` | `"xsmall"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment_name"></a> [global\_environment\_name](#input\_global\_environment\_name) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | True if the default provider already has access to the backend | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | List of required tag names | `list(string)` | `[]` | no |
| <a name="input_root_account_stage_name"></a> [root\_account\_stage\_name](#input\_root\_account\_stage\_name) | The stage name for the AWS Organization root (master) account | `string` | `"root"` | no |
| <a name="input_service_user_id"></a> [service\_user\_id](#input\_service\_user\_id) | The identifier for the service user created to manage infrastructure. | `string` | `"terraform"` | no |
| <a name="input_snowflake_account"></a> [snowflake\_account](#input\_snowflake\_account) | The Snowflake account given with the AWS Marketplace Subscription. | `string` | n/a | yes |
| <a name="input_snowflake_account_region"></a> [snowflake\_account\_region](#input\_snowflake\_account\_region) | AWS Region with the Snowflake subscription | `string` | n/a | yes |
| <a name="input_snowflake_admin_username"></a> [snowflake\_admin\_username](#input\_snowflake\_admin\_username) | Snowflake admin username created with the initial account subscription. | `string` | `"admin"` | no |
| <a name="input_snowflake_role_description"></a> [snowflake\_role\_description](#input\_snowflake\_role\_description) | Comment to attach to the Snowflake Role. | `string` | `"Terraform service user role."` | no |
| <a name="input_snowflake_username_format"></a> [snowflake\_username\_format](#input\_snowflake\_username\_format) | Snowflake username format | `string` | `"%s-%s"` | no |
| <a name="input_ssm_path_snowflake_user_format"></a> [ssm\_path\_snowflake\_user\_format](#input\_ssm\_path\_snowflake\_user\_format) | SSM parameter path format for a Snowflake user. For example, /snowflake/{{ account }}/users/{{ username }}/ | `string` | `"/%s/%s/%s/%s/%s"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_terraform_user_first_name"></a> [terraform\_user\_first\_name](#input\_terraform\_user\_first\_name) | Snowflake Terraform first name given with User creation | `string` | `"Terraform"` | no |
| <a name="input_terraform_user_last_name"></a> [terraform\_user\_last\_name](#input\_terraform\_user\_last\_name) | Snowflake Terraform last name given with User creation | `string` | `"User"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_snowflake_account"></a> [snowflake\_account](#output\_snowflake\_account) | The Snowflake account ID. |
| <a name="output_snowflake_region"></a> [snowflake\_region](#output\_snowflake\_region) | The AWS Region with the Snowflake account. |
| <a name="output_snowflake_terraform_role"></a> [snowflake\_terraform\_role](#output\_snowflake\_terraform\_role) | The name of the role given to the Terraform service user. |
| <a name="output_ssm_path_terraform_user_name"></a> [ssm\_path\_terraform\_user\_name](#output\_ssm\_path\_terraform\_user\_name) | The path to the SSM parameter for the Terraform user name. |
| <a name="output_ssm_path_terraform_user_private_key"></a> [ssm\_path\_terraform\_user\_private\_key](#output\_ssm\_path\_terraform\_user\_private\_key) | The path to the SSM parameter for the Terraform user private key. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
