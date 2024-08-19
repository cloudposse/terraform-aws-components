---
tags:
  - component/glue/crawler
  - layer/unassigned
  - provider/aws
---

# Component: `glue/crawler`

This component provisions Glue crawlers.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    # The crawler crawls the data in an S3 bucket and puts the results into a table in the Glue Catalog.
    # The crawler will read the first 2 MB of data from the file, and recognize the schema.
    # After that, the crawler will sync the table.
    glue/crawler/example:
      metadata:
        component: glue/crawler
      vars:
        enabled: true
        name: example
        crawler_description: "Glue crawler example"
        glue_iam_component_name: "glue/iam"
        glue_catalog_database_component_name: "glue/catalog-database/example"
        glue_catalog_table_component_name: "glue/catalog-table/example"
        schedule: "cron(0 1 * * ? *)"
        schema_change_policy:
          delete_behavior: LOG
          update_behavior: null
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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_glue_catalog_database"></a> [glue\_catalog\_database](#module\_glue\_catalog\_database) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_glue_catalog_table"></a> [glue\_catalog\_table](#module\_glue\_catalog\_table) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_glue_crawler"></a> [glue\_crawler](#module\_glue\_crawler) | cloudposse/glue/aws//modules/glue-crawler | 0.4.0 |
| <a name="module_glue_iam_role"></a> [glue\_iam\_role](#module\_glue\_iam\_role) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_catalog_target"></a> [catalog\_target](#input\_catalog\_target) | List of nested Glue catalog target arguments | <pre>list(object({<br>    database_name = string<br>    tables        = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_classifiers"></a> [classifiers](#input\_classifiers) | List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification | `list(string)` | `null` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | JSON string of configuration information | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_crawler_description"></a> [crawler\_description](#input\_crawler\_description) | Glue crawler description | `string` | `null` | no |
| <a name="input_crawler_name"></a> [crawler\_name](#input\_crawler\_name) | Glue crawler name. If not provided, the name will be generated from the context | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_delta_target"></a> [delta\_target](#input\_delta\_target) | List of nested Delta target arguments | <pre>list(object({<br>    connection_name = string<br>    delta_tables    = list(string)<br>    write_manifest  = bool<br>  }))</pre> | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dynamodb_target"></a> [dynamodb\_target](#input\_dynamodb\_target) | List of nested DynamoDB target arguments | `list(any)` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_glue_catalog_database_component_name"></a> [glue\_catalog\_database\_component\_name](#input\_glue\_catalog\_database\_component\_name) | Glue catalog database component name where metadata resides. Used to get the Glue catalog database from the remote state | `string` | n/a | yes |
| <a name="input_glue_catalog_table_component_name"></a> [glue\_catalog\_table\_component\_name](#input\_glue\_catalog\_table\_component\_name) | Glue catalog table component name where metadata resides. Used to get the Glue catalog table from the remote state | `string` | `null` | no |
| <a name="input_glue_iam_component_name"></a> [glue\_iam\_component\_name](#input\_glue\_iam\_component\_name) | Glue IAM component name. Used to get the Glue IAM role from the remote state | `string` | `"glue/iam"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_jdbc_target"></a> [jdbc\_target](#input\_jdbc\_target) | List of nested JBDC target arguments | `list(any)` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lineage_configuration"></a> [lineage\_configuration](#input\_lineage\_configuration) | Specifies data lineage configuration settings for the crawler | <pre>object({<br>    crawler_lineage_settings = string<br>  })</pre> | `null` | no |
| <a name="input_mongodb_target"></a> [mongodb\_target](#input\_mongodb\_target) | List of nested MongoDB target arguments | `list(any)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_recrawl_policy"></a> [recrawl\_policy](#input\_recrawl\_policy) | A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run | <pre>object({<br>    recrawl_behavior = string<br>  })</pre> | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_s3_target"></a> [s3\_target](#input\_s3\_target) | List of nested Amazon S3 target arguments | `list(any)` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | A cron expression for the schedule | `string` | `null` | no |
| <a name="input_schema_change_policy"></a> [schema\_change\_policy](#input\_schema\_change\_policy) | Policy for the crawler's update and deletion behavior | `map(string)` | `null` | no |
| <a name="input_security_configuration"></a> [security\_configuration](#input\_security\_configuration) | The name of Security Configuration to be used by the crawler | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_table_prefix"></a> [table\_prefix](#input\_table\_prefix) | The table prefix used for catalog tables that are created | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_crawler_arn"></a> [crawler\_arn](#output\_crawler\_arn) | Crawler ARN |
| <a name="output_crawler_id"></a> [crawler\_id](#output\_crawler\_id) | Crawler ID |
| <a name="output_crawler_name"></a> [crawler\_name](#output\_crawler\_name) | Crawler name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/glue/crawler) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
