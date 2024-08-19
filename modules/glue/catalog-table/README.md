---
tags:
  - component/glue/catalog-table
  - layer/unassigned
  - provider/aws
---

# Component: `glue/catalog-table`

This component provisions Glue catalog tables.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    glue/catalog-table/example:
      metadata:
        component: glue/catalog-table
      vars:
        enabled: true
        name: example
        catalog_table_description: Glue catalog table example
        glue_iam_component_name: glue/iam
        glue_catalog_database_component_name: glue/catalog-database/example
        lakeformation_permissions_enabled: true
        lakeformation_permissions:
          - "ALL"
        storage_descriptor:
          location: "s3://awsglue-datasets/examples/medicare/Medicare_Hospital_Provider.csv"
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 1.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_glue_catalog_database"></a> [glue\_catalog\_database](#module\_glue\_catalog\_database) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_glue_catalog_table"></a> [glue\_catalog\_table](#module\_glue\_catalog\_table) | cloudposse/glue/aws//modules/glue-catalog-table | 0.4.0 |
| <a name="module_glue_iam_role"></a> [glue\_iam\_role](#module\_glue\_iam\_role) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lakeformation_permissions.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name | `string` | `null` | no |
| <a name="input_catalog_table_description"></a> [catalog\_table\_description](#input\_catalog\_table\_description) | Description of the table | `string` | `null` | no |
| <a name="input_catalog_table_name"></a> [catalog\_table\_name](#input\_catalog\_table\_name) | Name of the table | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_glue_catalog_database_component_name"></a> [glue\_catalog\_database\_component\_name](#input\_glue\_catalog\_database\_component\_name) | Glue catalog database component name where the table metadata resides. Used to get the Glue catalog database from the remote state | `string` | n/a | yes |
| <a name="input_glue_iam_component_name"></a> [glue\_iam\_component\_name](#input\_glue\_iam\_component\_name) | Glue IAM component name. Used to get the Glue IAM role from the remote state | `string` | `"glue/iam"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lakeformation_permissions"></a> [lakeformation\_permissions](#input\_lakeformation\_permissions) | List of permissions granted to the principal. Refer to https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-reference.html for more details | `list(string)` | <pre>[<br>  "ALL"<br>]</pre> | no |
| <a name="input_lakeformation_permissions_enabled"></a> [lakeformation\_permissions\_enabled](#input\_lakeformation\_permissions\_enabled) | Whether to enable adding Lake Formation permissions to the IAM role that is used to access the Glue table | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the table | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Properties associated with this table, as a map of key-value pairs | `map(string)` | `null` | no |
| <a name="input_partition_index"></a> [partition\_index](#input\_partition\_index) | Configuration block for a maximum of 3 partition indexes | <pre>object({<br>    index_name = string<br>    keys       = list(string)<br>  })</pre> | `null` | no |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys | `map(string)` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_retention"></a> [retention](#input\_retention) | Retention time for the table | `number` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_storage_descriptor"></a> [storage\_descriptor](#input\_storage\_descriptor) | Configuration block for information about the physical storage of this table | `any` | `null` | no |
| <a name="input_table_type"></a> [table\_type](#input\_table\_type) | Type of this table (`EXTERNAL_TABLE`, `VIRTUAL_VIEW`, etc.). While optional, some Athena DDL queries such as `ALTER TABLE` and `SHOW CREATE TABLE` will fail if this argument is empty | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_target_table"></a> [target\_table](#input\_target\_table) | Configuration block of a target table for resource linking | <pre>object({<br>    catalog_id    = string<br>    database_name = string<br>    name          = string<br>  })</pre> | `null` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_view_expanded_text"></a> [view\_expanded\_text](#input\_view\_expanded\_text) | If the table is a view, the expanded text of the view; otherwise null | `string` | `null` | no |
| <a name="input_view_original_text"></a> [view\_original\_text](#input\_view\_original\_text) | If the table is a view, the original text of the view; otherwise null | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_catalog_table_arn"></a> [catalog\_table\_arn](#output\_catalog\_table\_arn) | Catalog table ARN |
| <a name="output_catalog_table_id"></a> [catalog\_table\_id](#output\_catalog\_table\_id) | Catalog table ID |
| <a name="output_catalog_table_name"></a> [catalog\_table\_name](#output\_catalog\_table\_name) | Catalog table name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/glue/catalog-table) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
