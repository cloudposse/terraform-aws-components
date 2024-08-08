# Component: `gitops`

This component is used to deploy GitHub OIDC roles for accessing the `gitops` Team. We use this team to run Terraform
from GitHub Actions.

Examples:

- [cloudposse/github-action-terraform-plan-storage](https://github.com/cloudposse/github-action-terraform-plan-storage/blob/main/.github/workflows/build-and-test.yml)

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
import:
  - catalog/s3-bucket/defaults
  - catalog/dynamodb/defaults

components:
  terraform:
    # S3 Bucket for storing Terraform Plans
    gitops/s3-bucket:
      metadata:
        component: s3-bucket
        inherits:
          - s3-bucket/defaults
      vars:
        name: gitops-plan-storage
        allow_encrypted_uploads_only: false

    # DynamoDB table used to store metadata for Terraform Plans
    gitops/dynamodb:
      metadata:
        component: dynamodb
        inherits:
          - dynamodb/defaults
      vars:
        name: gitops-plan-storage
        # These keys (case-sensitive) are required for the cloudposse/github-action-terraform-plan-storage action
        hash_key: id
        range_key: createdAt

    gitops:
      vars:
        enabled: true
        github_actions_iam_role_enabled: true
        github_actions_iam_role_attributes: ["gitops"]
        github_actions_allowed_repos:
          - "acmeOrg/infra"
        s3_bucket_component_name: gitops/s3-bucket
        dynamodb_component_name: gitops/dynamodb
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_gha_assume_role"></a> [gha\_assume\_role](#module\_gha\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_gha_role_name"></a> [gha\_role\_name](#module\_gha\_role\_name) | cloudposse/label/null | 0.25.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.github_actions_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dynamodb_component_name"></a> [dynamodb\_component\_name](#input\_dynamodb\_component\_name) | The name of the dynamodb component used to store Terraform state | `string` | `"gitops/dynamodb"` | no |
| <a name="input_dynamodb_environment_name"></a> [dynamodb\_environment\_name](#input\_dynamodb\_environment\_name) | The name of the dynamodb environment used to store Terraform state | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_actions_allowed_repos"></a> [github\_actions\_allowed\_repos](#input\_github\_actions\_allowed\_repos) | A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br>  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br>  If org part of repo name is omitted, "cloudposse" will be assumed. | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_attributes"></a> [github\_actions\_iam\_role\_attributes](#input\_github\_actions\_iam\_role\_attributes) | Additional attributes to add to the role name | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_enabled"></a> [github\_actions\_iam\_role\_enabled](#input\_github\_actions\_iam\_role\_enabled) | Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_s3_bucket_component_name"></a> [s3\_bucket\_component\_name](#input\_s3\_bucket\_component\_name) | The name of the s3\_bucket component used to store Terraform state | `string` | `"gitops/s3-bucket"` | no |
| <a name="input_s3_bucket_environment_name"></a> [s3\_bucket\_environment\_name](#input\_s3\_bucket\_environment\_name) | The name of the s3\_bucket environment used to store Terraform state | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_iam_role_arn"></a> [github\_actions\_iam\_role\_arn](#output\_github\_actions\_iam\_role\_arn) | ARN of IAM role for GitHub Actions |
| <a name="output_github_actions_iam_role_name"></a> [github\_actions\_iam\_role\_name](#output\_github\_actions\_iam\_role\_name) | Name of IAM role for GitHub Actions |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/gitops) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
