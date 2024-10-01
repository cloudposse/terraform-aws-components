# Component: `access-analyzer`

This component is responsible for configuring AWS Identity and Access Management Access Analyzer within an AWS
Organization.

IAM Access Analyzer helps you identify the resources in your organization and accounts, such as Amazon S3 buckets or IAM
roles, shared with an external entity. This lets you identify unintended access to your resources and data, which is a
security risk. IAM Access Analyzer identifies resources shared with external principals by using logic-based reasoning
to analyze the resource-based policies in your AWS environment. For each instance of a resource shared outside of your
account, IAM Access Analyzer generates a finding. Findings include information about the access and the external
principal granted to it. You can review findings to determine if the access is intended and safe or if the access is
unintended and a security risk. In addition to helping you identify resources shared with an external entity, you can
use IAM Access Analyzer findings to preview how your policy affects public and cross-account access to your resource
before deploying resource permissions. The findings are organized in a visual summary dashboard. The dashboard
highlights the split between public and cross-account access findings, and provides a breakdown of findings by resource
type.

IAM Access Analyzer analyzes only policies applied to resources in the same AWS Region where it's enabled. To monitor
all resources in your AWS environment, you must create an analyzer to enable IAM Access Analyzer in each Region where
you're using supported AWS resources.

AWS Identity and Access Management Access Analyzer provides the following capabilities:

- IAM Access Analyzer external access analyzers help identify resources in your organization and accounts that are
  shared with an external entity.

- IAM Access Analyzer unused access analyzers help identify unused access in your organization and accounts.

- IAM Access Analyzer validates IAM policies against policy grammar and AWS best practices.

- IAM Access Analyzer custom policy checks help validate IAM policies against your specified security standards.

- IAM Access Analyzer generates IAM policies based on access activity in your AWS CloudTrail logs.

Here's a typical workflow:

**Delegate Access Analyzer to another account**: From the Organization management (root) account, delegate
administration to a specific AWS account within your organization (usually the security account).

**Create Access Analyzers in the Delegated Administrator Account**: Enable the Access Analyzers for external access and
unused access in the delegated administrator account.

## Deployment Overview

```yaml
components:
  terraform:
    access-analyzer/defaults:
      metadata:
        component: access-analyzer
        type: abstract
      vars:
        enabled: true
        global_environment: gbl
        account_map_tenant: core
        root_account_stage: root
        delegated_administrator_account_name: core-mgt
        accessanalyzer_service_principal: "access-analyzer.amazonaws.com"
        accessanalyzer_organization_enabled: false
        accessanalyzer_organization_unused_access_enabled: false
        organizations_delegated_administrator_enabled: false
```

```yaml
import:
  - catalog/access-analyzer/defaults

components:
  terraform:
    access-analyzer/root:
      metadata:
        component: access-analyzer
        inherits:
          - access-analyzer/defaults
      vars:
        organizations_delegated_administrator_enabled: true
```

```yaml
import:
  - catalog/access-analyzer/defaults

components:
  terraform:
    access-analyzer/delegated-administrator:
      metadata:
        component: access-analyzer
        inherits:
          - access-analyzer/defaults
      vars:
        accessanalyzer_organization_enabled: true
        accessanalyzer_organization_unused_access_enabled: true
        unused_access_age: 30
```

### Provisioning

Delegate Access Analyzer to the security account:

```bash
atmos terraform apply access-analyzer/root -s plat-dev-gbl-root
```

Provision Access Analyzers for external access and unused access in the delegated administrator (security) account in
each region:

```bash
atmos terraform apply access-analyzer/delegated-administrator -s plat-dev-use1-mgt
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_accessanalyzer_analyzer.organization_unused_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_organizations_delegated_administrator.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accessanalyzer_organization_enabled"></a> [accessanalyzer\_organization\_enabled](#input\_accessanalyzer\_organization\_enabled) | Flag to enable the Organization Access Analyzer | `bool` | n/a | yes |
| <a name="input_accessanalyzer_organization_unused_access_enabled"></a> [accessanalyzer\_organization\_unused\_access\_enabled](#input\_accessanalyzer\_organization\_unused\_access\_enabled) | Flag to enable the Organization unused access Access Analyzer | `bool` | n/a | yes |
| <a name="input_accessanalyzer_service_principal"></a> [accessanalyzer\_service\_principal](#input\_accessanalyzer\_service\_principal) | The Access Analyzer service principal for which you want to make the member account a delegated administrator | `string` | `"access-analyzer.amazonaws.com"` | no |
| <a name="input_account_map_tenant"></a> [account\_map\_tenant](#input\_account\_map\_tenant) | The tenant where the `account_map` component required by remote-state is deployed | `string` | n/a | yes |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delegated_administrator_account_name"></a> [delegated\_administrator\_account\_name](#input\_delegated\_administrator\_account\_name) | The name of the account that is the AWS Organization Delegated Administrator account | `string` | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment"></a> [global\_environment](#input\_global\_environment) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_organization_management_account_name"></a> [organization\_management\_account\_name](#input\_organization\_management\_account\_name) | The name of the AWS Organization management account | `string` | `null` | no |
| <a name="input_organizations_delegated_administrator_enabled"></a> [organizations\_delegated\_administrator\_enabled](#input\_organizations\_delegated\_administrator\_enabled) | Flag to enable the Organization delegated administrator | `bool` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_stage"></a> [root\_account\_stage](#input\_root\_account\_stage) | The stage name for the Organization root (management) account. This is used to lookup account IDs from account names<br>using the `account-map` component. | `string` | `"root"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_unused_access_age"></a> [unused\_access\_age](#input\_unused\_access\_age) | The specified access age in days for which to generate findings for unused access | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_organizations_delegated_administrator_id"></a> [aws\_organizations\_delegated\_administrator\_id](#output\_aws\_organizations\_delegated\_administrator\_id) | AWS Organizations Delegated Administrator ID |
| <a name="output_aws_organizations_delegated_administrator_status"></a> [aws\_organizations\_delegated\_administrator\_status](#output\_aws\_organizations\_delegated\_administrator\_status) | AWS Organizations Delegated Administrator status |
| <a name="output_organization_accessanalyzer_id"></a> [organization\_accessanalyzer\_id](#output\_organization\_accessanalyzer\_id) | Organization Access Analyzer ID |
| <a name="output_organization_unused_access_accessanalyzer_id"></a> [organization\_unused\_access\_accessanalyzer\_id](#output\_organization\_unused\_access\_accessanalyzer\_id) | Organization unused access Access Analyzer ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- https://aws.amazon.com/iam/access-analyzer/
- https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html
- https://repost.aws/knowledge-center/iam-access-analyzer-organization
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer
- https://github.com/hashicorp/terraform-provider-aws/issues/19312
- https://github.com/hashicorp/terraform-provider-aws/pull/19389
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator
