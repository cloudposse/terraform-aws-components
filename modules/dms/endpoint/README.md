---
tags:
  - component/dms/endpoint
  - layer/unassigned
  - provider/aws
---

# Component: `dms/endpoint`

This component provisions DMS endpoints.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
components:
  terraform:
    dms/endpoint/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
          autodeploy: false
      vars:
        enabled: true

    dms-endpoint-source-example:
      metadata:
        component: dms/endpoint
        inherits:
          - dms/endpoint/defaults
      vars:
        name: source-example
        endpoint_type: source
        engine_name: aurora-postgresql
        server_name: ""
        database_name: ""
        port: 5432
        extra_connection_attributes: ""
        secrets_manager_access_role_arn: ""
        secrets_manager_arn: ""
        ssl_mode: none
        attributes:
          - source

    dms-endpoint-target-example:
      metadata:
        component: dms/endpoint
        inherits:
          - dms/endpoint/defaults
      vars:
        name: target-example
        endpoint_type: target
        engine_name: s3
        extra_connection_attributes: ""
        s3_settings:
          bucket_name: ""
          bucket_folder: null
          cdc_inserts_only: false
          csv_row_delimiter: " "
          csv_delimiter: ","
          data_format: parquet
          compression_type: GZIP
          date_partition_delimiter: NONE
          date_partition_enabled: true
          date_partition_sequence: YYYYMMDD
          include_op_for_full_load: true
          parquet_timestamp_in_millisecond: true
          timestamp_column_name: timestamp
          service_access_role_arn: ""
        attributes:
          - target
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dms_endpoint"></a> [dms\_endpoint](#module\_dms\_endpoint) | cloudposse/dms/aws//modules/dms-endpoint | 0.1.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate ARN | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the endpoint database | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_elasticsearch_settings"></a> [elasticsearch\_settings](#input\_elasticsearch\_settings) | Configuration block for OpenSearch settings | `map(any)` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | Type of endpoint. Valid values are `source`, `target` | `string` | n/a | yes |
| <a name="input_engine_name"></a> [engine\_name](#input\_engine\_name) | Type of engine for the endpoint. Valid values are `aurora`, `aurora-postgresql`, `azuredb`, `db2`, `docdb`, `dynamodb`, `elasticsearch`, `kafka`, `kinesis`, `mariadb`, `mongodb`, `mysql`, `opensearch`, `oracle`, `postgres`, `redshift`, `s3`, `sqlserver`, `sybase` | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_extra_connection_attributes"></a> [extra\_connection\_attributes](#input\_extra\_connection\_attributes) | Additional attributes associated with the connection to the source database | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kafka_settings"></a> [kafka\_settings](#input\_kafka\_settings) | Configuration block for Kafka settings | `map(any)` | `null` | no |
| <a name="input_kinesis_settings"></a> [kinesis\_settings](#input\_kinesis\_settings) | Configuration block for Kinesis settings | `map(any)` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Required when engine\_name is `mongodb`, optional otherwise). ARN for the KMS key that will be used to encrypt the connection parameters. If you do not specify a value for `kms_key_arn`, then AWS DMS will use your default encryption key | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_mongodb_settings"></a> [mongodb\_settings](#input\_mongodb\_settings) | Configuration block for MongoDB settings | `map(any)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_password"></a> [password](#input\_password) | Password to be used to login to the endpoint database | `string` | `""` | no |
| <a name="input_password_path"></a> [password\_path](#input\_password\_path) | If set, the path in AWS SSM Parameter Store to fetch the password for the DMS admin user | `string` | `""` | no |
| <a name="input_port"></a> [port](#input\_port) | Port used by the endpoint database | `number` | `null` | no |
| <a name="input_redshift_settings"></a> [redshift\_settings](#input\_redshift\_settings) | Configuration block for Redshift settings | `map(any)` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_s3_settings"></a> [s3\_settings](#input\_s3\_settings) | Configuration block for S3 settings | `map(any)` | `null` | no |
| <a name="input_secrets_manager_access_role_arn"></a> [secrets\_manager\_access\_role\_arn](#input\_secrets\_manager\_access\_role\_arn) | ARN of the IAM role that specifies AWS DMS as the trusted entity and has the required permissions to access the value in SecretsManagerSecret | `string` | `null` | no |
| <a name="input_secrets_manager_arn"></a> [secrets\_manager\_arn](#input\_secrets\_manager\_arn) | Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine\_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver | `string` | `null` | no |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | Host name of the database server | `string` | `null` | no |
| <a name="input_service_access_role"></a> [service\_access\_role](#input\_service\_access\_role) | ARN used by the service access IAM role for DynamoDB endpoints | `string` | `null` | no |
| <a name="input_ssl_mode"></a> [ssl\_mode](#input\_ssl\_mode) | The SSL mode to use for the connection. Can be one of `none`, `require`, `verify-ca`, `verify-full` | `string` | `"none"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | User name to be used to login to the endpoint database | `string` | `""` | no |
| <a name="input_username_path"></a> [username\_path](#input\_username\_path) | If set, the path in AWS SSM Parameter Store to fetch the username for the DMS admin user | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_endpoint_arn"></a> [dms\_endpoint\_arn](#output\_dms\_endpoint\_arn) | DMS endpoint ARN |
| <a name="output_dms_endpoint_id"></a> [dms\_endpoint\_id](#output\_dms\_endpoint\_id) | DMS endpoint ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dms/modules/dms-endpoint) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
