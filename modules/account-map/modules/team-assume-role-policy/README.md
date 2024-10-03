# team-assume-role-policy

This submodule generates a JSON-encoded IAM Policy Document suitable for use as an "Assume Role Policy".

You can designate both who is allowed to assume a role and who is explicitly denied permission to assume a role. The
value of this submodule is that it allows for many ways to specify the "who" while at the same time limiting the "who"
to assumed IAM roles:

- All assumed roles in the `dev` account: `allowed_roles = { dev = ["*"] }`
- Only the `admin` role in the dev account: `allowed_roles = { dev = ["admin"] }`
- A specific principal in any account (though it must still be an assumed role):
  `allowed_principal_arns = arn:aws:iam::123456789012:role/trusted-role`
- A user of a specific AWS SSO Permission Set: `allowed_permission_sets = { dev = ["DeveloperAccess"] }`

## Usage

```hcl

module "assume_role" {
  source   = "../account-map/modules/team-assume-role-policy"

  allowed_roles = { dev = ["admin"] }

  context = module.this.context
}

resource "aws_iam_role" "default" {
  assume_role_policy = module.assume_role.policy_document

  # ...
}
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_allowed_role_map"></a> [allowed\_role\_map](#module\_allowed\_role\_map) | ../../../account-map/modules/roles-to-principals | n/a |
| <a name="module_denied_role_map"></a> [denied\_role\_map](#module\_denied\_role\_map) | ../../../account-map/modules/roles-to-principals | n/a |
| <a name="module_github_oidc_provider"></a> [github\_oidc\_provider](#module\_github\_oidc\_provider) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_arn.allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_arn.denied](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_oidc_provider_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allowed_permission_sets"></a> [allowed\_permission\_sets](#input\_allowed\_permission\_sets) | Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets allowed to assume the role when coming from specified account | `map(list(string))` | `{}` | no |
| <a name="input_allowed_principal_arns"></a> [allowed\_principal\_arns](#input\_allowed\_principal\_arns) | List of AWS principal ARNs allowed to assume the role. | `list(string)` | `[]` | no |
| <a name="input_allowed_roles"></a> [allowed\_roles](#input\_allowed\_roles) | Map of account:[role, role...] specifying roles allowed to assume the role.<br>Roles are symbolic names like `ops` or `terraform`. Use `*` as role for entire account. | `map(list(string))` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_denied_permission_sets"></a> [denied\_permission\_sets](#input\_denied\_permission\_sets) | Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets denied access to the role when coming from specified account | `map(list(string))` | `{}` | no |
| <a name="input_denied_principal_arns"></a> [denied\_principal\_arns](#input\_denied\_principal\_arns) | List of AWS principal ARNs explicitly denied access to the role. | `list(string)` | `[]` | no |
| <a name="input_denied_roles"></a> [denied\_roles](#input\_denied\_roles) | Map of account:[role, role...] specifying roles explicitly denied permission to assume the role.<br>Roles are symbolic names like `ops` or `terraform`. Use `*` as role for entire account. | `map(list(string))` | `{}` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment_name"></a> [global\_environment\_name](#input\_global\_environment\_name) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_iam_users_enabled"></a> [iam\_users\_enabled](#input\_iam\_users\_enabled) | True if you would like IAM Users to be able to assume the role. | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | True if the default provider already has access to the backend | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_trusted_github_org"></a> [trusted\_github\_org](#input\_trusted\_github\_org) | The GitHub organization unqualified repos are assumed to belong to. Keeps `*` from meaning all orgs and all repos. | `string` | `"cloudposse"` | no |
| <a name="input_trusted_github_repos"></a> [trusted\_github\_repos](#input\_trusted\_github\_repos) | A list of GitHub repositories allowed to access this role.<br>Format is either "orgName/repoName" or just "repoName",<br>in which case "cloudposse" will be used for the "orgName".<br>Wildcard ("*") is allowed for "repoName". | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_assume_role_policy"></a> [github\_assume\_role\_policy](#output\_github\_assume\_role\_policy) | JSON encoded string representing the "Assume Role" policy configured by the inputs |
| <a name="output_policy_document"></a> [policy\_document](#output\_policy\_document) | JSON encoded string representing the "Assume Role" policy configured by the inputs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
