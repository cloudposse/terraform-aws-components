# Component: `account-map`

This component is responsible for provisioning information only: it simply populates Terraform state with data (account ids, groups, and roles) that other root modules need via outputs.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. Stick this snippet in the management account's stack (E.g. `gbl-root.yaml`)

```yaml
components:
  terraform:
    account-map:
      vars:
        enabled: true
        # If this is true, profile must be provided instead of role_arn in each backend.tf.json
        # If this is false, role_arn must be provided instead of profile in each backend.tf.json
        profiles_enabled: false
        root_account_aws_name: "aws-root"
        root_account_account_name: root
        identity_account_account_name: identity
        dns_account_account_name: dns
        audit_account_account_name: audit
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_accounts"></a> [accounts](#module\_accounts) | cloudposse/stack-config/yaml//modules/remote-state | 0.19.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_artifacts_account_account_name"></a> [artifacts\_account\_account\_name](#input\_artifacts\_account\_account\_name) | The stage name for the artifacts account | `string` | `"artifacts"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_audit_account_account_name"></a> [audit\_account\_account\_name](#input\_audit\_account\_account\_name) | The stage name for the audit account | `string` | `"audit"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_account_account_name"></a> [dns\_account\_account\_name](#input\_dns\_account\_account\_name) | The stage name for the primary DNS account | `string` | `"dns"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment_name"></a> [global\_environment\_name](#input\_global\_environment\_name) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_iam_role_arn_template"></a> [iam\_role\_arn\_template](#input\_iam\_role\_arn\_template) | The template used to render Role ARNs.<br><br>Note that if the `null-label` variable `label_order` is truncated or extended with additional labels, this template will<br>need to be updated to reflect the new number of labels. | `string` | `"arn:aws:iam::%s:role/%s-%s-%s-%s"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_identity_account_account_name"></a> [identity\_account\_account\_name](#input\_identity\_account\_account\_name) | The stage name for the account holding primary IAM roles | `string` | `"identity"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_profile_template"></a> [profile\_template](#input\_profile\_template) | The template used to render AWS Profile names.<br><br>Note that if the `null-label` variable `label_order` is truncated or extended with additional labels, this template will<br>need to be updated to reflect the new number of labels. | `string` | `"%s-%s-%s-%s"` | no |
| <a name="input_profiles_enabled"></a> [profiles\_enabled](#input\_profiles\_enabled) | Whether or not to enable profiles instead of roles for the backend. If true, profile must be set. If false, role\_arn must be set. | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_account_name"></a> [root\_account\_account\_name](#input\_root\_account\_account\_name) | The stage name for the root account | `string` | `"root"` | no |
| <a name="input_root_account_aws_name"></a> [root\_account\_aws\_name](#input\_root\_account\_aws\_name) | The name of the root account as reported by AWS | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_info_map"></a> [account\_info\_map](#output\_account\_info\_map) | A map from account name to various information about the account.<br>See the `account_info_map` output of `account` for more detail. |
| <a name="output_all_accounts"></a> [all\_accounts](#output\_all\_accounts) | A list of all accounts in the AWS Organization |
| <a name="output_artifacts_account_account_name"></a> [artifacts\_account\_account\_name](#output\_artifacts\_account\_account\_name) | The short name for the artifacts account |
| <a name="output_audit_account_account_name"></a> [audit\_account\_account\_name](#output\_audit\_account\_account\_name) | The short name for the audit account |
| <a name="output_cicd_profiles"></a> [cicd\_profiles](#output\_cicd\_profiles) | A list of all SSO profiles used by cicd platforms |
| <a name="output_cicd_roles"></a> [cicd\_roles](#output\_cicd\_roles) | A list of all IAM roles used by cicd platforms |
| <a name="output_dns_account_account_name"></a> [dns\_account\_account\_name](#output\_dns\_account\_account\_name) | The short name for the primary DNS account |
| <a name="output_eks_accounts"></a> [eks\_accounts](#output\_eks\_accounts) | A list of all accounts in the AWS Organization that contain EKS clusters |
| <a name="output_full_account_map"></a> [full\_account\_map](#output\_full\_account\_map) | The map of account name to account ID (number). |
| <a name="output_helm_profiles"></a> [helm\_profiles](#output\_helm\_profiles) | A list of all SSO profiles used to run helm updates |
| <a name="output_helm_roles"></a> [helm\_roles](#output\_helm\_roles) | A list of all IAM roles used to run helm updates |
| <a name="output_identity_account_account_name"></a> [identity\_account\_account\_name](#output\_identity\_account\_account\_name) | The short name for the account holding primary IAM roles |
| <a name="output_non_eks_accounts"></a> [non\_eks\_accounts](#output\_non\_eks\_accounts) | A list of all accounts in the AWS Organization that do not contain EKS clusters |
| <a name="output_org"></a> [org](#output\_org) | The name of the AWS Organization |
| <a name="output_profiles_enabled"></a> [profiles\_enabled](#output\_profiles\_enabled) | Whether or not to enable profiles instead of roles for the backend |
| <a name="output_root_account_account_name"></a> [root\_account\_account\_name](#output\_root\_account\_account\_name) | The short name for the root account |
| <a name="output_root_account_aws_name"></a> [root\_account\_aws\_name](#output\_root\_account\_aws\_name) | The name of the root account as reported by AWS |
| <a name="output_terraform_profiles"></a> [terraform\_profiles](#output\_terraform\_profiles) | A list of all SSO profiles used to run terraform updates |
| <a name="output_terraform_roles"></a> [terraform\_roles](#output\_terraform\_roles) | A list of all IAM roles used to run terraform updates |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/account-map) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
