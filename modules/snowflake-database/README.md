---
tags:
  - component/snowflake-database
  - layer/unassigned
  - provider/aws
  - provider/snowflake
---

# Component: `snowflake-database`

All data in Snowflake is stored in database tables, logically structured as collections of columns and rows. This
component will create and control a Snowflake database, schema, and set of tables.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    snowflake-database:
      vars:
        enabled: true
        tags:
          Team: data
          Service: snowflake
        tables:
          example:
            comment: "An example table"
            columns:
              - name: "data"
                type: "text"
              - name: "DATE"
                type: "TIMESTAMP_NTZ(9)"
              - name: "extra"
                type: "VARIANT"
                comment: "extra data"
            primary_key:
              name: "pk"
              keys:
                - "data"
        views:
          select-example:
            comment: "An example view"
            statement: |
              select * from "example";
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 0.25 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 0.25 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_introspection"></a> [introspection](#module\_introspection) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_account"></a> [snowflake\_account](#module\_snowflake\_account) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_snowflake_database"></a> [snowflake\_database](#module\_snowflake\_database) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_label"></a> [snowflake\_label](#module\_snowflake\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_schema"></a> [snowflake\_schema](#module\_snowflake\_schema) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_sequence"></a> [snowflake\_sequence](#module\_snowflake\_sequence) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 0.8.1 |

## Resources

| Name | Type |
|------|------|
| [snowflake_database.this](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/database) | resource |
| [snowflake_database_grant.grant](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/database_grant) | resource |
| [snowflake_schema.this](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/schema) | resource |
| [snowflake_schema_grant.grant](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/schema_grant) | resource |
| [snowflake_sequence.this](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/sequence) | resource |
| [snowflake_table.tables](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/table) | resource |
| [snowflake_table_grant.grant](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/table_grant) | resource |
| [snowflake_view.view](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/view) | resource |
| [snowflake_view_grant.grant](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/view_grant) | resource |
| [aws_ssm_parameter.snowflake_private_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.snowflake_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_data_retention_time_in_days"></a> [data\_retention\_time\_in\_days](#input\_data\_retention\_time\_in\_days) | Time in days to retain data in Snowflake databases, schemas, and tables by default. | `string` | `1` | no |
| <a name="input_database_comment"></a> [database\_comment](#input\_database\_comment) | The comment to give to the provisioned database. | `string` | `"A database created for managing programmatically created Snowflake schemas and tables."` | no |
| <a name="input_database_grants"></a> [database\_grants](#input\_database\_grants) | A list of Grants to give to the database created with component. | `list(string)` | <pre>[<br>  "MODIFY",<br>  "MONITOR",<br>  "USAGE"<br>]</pre> | no |
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
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | List of required tag names | `list(string)` | `[]` | no |
| <a name="input_schema_grants"></a> [schema\_grants](#input\_schema\_grants) | A list of Grants to give to the schema created with component. | `list(string)` | <pre>[<br>  "MODIFY",<br>  "MONITOR",<br>  "USAGE",<br>  "CREATE TABLE",<br>  "CREATE VIEW"<br>]</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_table_grants"></a> [table\_grants](#input\_table\_grants) | A list of Grants to give to the tables created with component. | `list(string)` | <pre>[<br>  "SELECT",<br>  "INSERT",<br>  "UPDATE",<br>  "DELETE",<br>  "TRUNCATE",<br>  "REFERENCES"<br>]</pre> | no |
| <a name="input_tables"></a> [tables](#input\_tables) | A map of tables to create for Snowflake. A schema and database will be assigned for this group of tables. | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_view_grants"></a> [view\_grants](#input\_view\_grants) | A list of Grants to give to the views created with component. | `list(string)` | <pre>[<br>  "SELECT",<br>  "REFERENCES"<br>]</pre> | no |
| <a name="input_views"></a> [views](#input\_views) | A map of views to create for Snowflake. The same schema and database will be assigned as for tables. | `map(any)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/snowflake-database) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
