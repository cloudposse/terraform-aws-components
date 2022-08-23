# Component: `datadog-lambda-forwarder`

This component is responsible for provision all the necessary infrastructure to 
deploy [Datadog Lambda forwarders](https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring). 


## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    datadog-lambda-forwarder:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        forwarder_log_enabled: true
        forwarder_rds_enabled: true
        forwarder_vpc_enabled: true
        dd_api_key_source:
          resource: "ssm"
          identifier: "datadog/datadog_api_key"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_lambda_forwarder"></a> [datadog\_lambda\_forwarder](#module\_datadog\_lambda\_forwarder) | cloudposse/datadog-lambda-forwarder/aws | 0.8.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_log_group_prefix"></a> [log\_group\_prefix](#module\_log\_group\_prefix) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_forwarder_log_groups"></a> [cloudwatch\_forwarder\_log\_groups](#input\_cloudwatch\_forwarder\_log\_groups) | Map of CloudWatch Log Groups with a filter pattern that the Lambda forwarder will send logs from. For example: { mysql1 = { name = "/aws/rds/maincluster", filter\_pattern = "" } | `map(map(string))` | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_context_tags"></a> [context\_tags](#input\_context\_tags) | List of context tags to add to each monitor | `set(string)` | <pre>[<br>  "namespace",<br>  "tenant",<br>  "environment",<br>  "stage"<br>]</pre> | no |
| <a name="input_context_tags_enabled"></a> [context\_tags\_enabled](#input\_context\_tags\_enabled) | Whether to add context tags to add to each monitor | `bool` | `true` | no |
| <a name="input_dd_api_key_kms_ciphertext_blob"></a> [dd\_api\_key\_kms\_ciphertext\_blob](#input\_dd\_api\_key\_kms\_ciphertext\_blob) | CiphertextBlob stored in environment variable DD\_KMS\_API\_KEY used by the lambda function, along with the KMS key, to decrypt Datadog API key | `string` | `""` | no |
| <a name="input_dd_api_key_source"></a> [dd\_api\_key\_source](#input\_dd\_api\_key\_source) | One of: ARN for AWS Secrets Manager (asm) to retrieve the Datadog (DD) api key, ARN for the KMS (kms) key used to decrypt the ciphertext\_blob of the api key, or the name of the SSM (ssm) parameter used to retrieve the Datadog API key | <pre>object({<br>    resource   = string<br>    identifier = string<br>  })</pre> | <pre>{<br>  "identifier": "",<br>  "resource": ""<br>}</pre> | no |
| <a name="input_dd_artifact_filename"></a> [dd\_artifact\_filename](#input\_dd\_artifact\_filename) | The Datadog artifact filename minus extension | `string` | `"aws-dd-forwarder"` | no |
| <a name="input_dd_forwarder_version"></a> [dd\_forwarder\_version](#input\_dd\_forwarder\_version) | Version tag of Datadog lambdas to use. https://github.com/DataDog/datadog-serverless-functions/releases | `string` | `"3.40.0"` | no |
| <a name="input_dd_module_name"></a> [dd\_module\_name](#input\_dd\_module\_name) | The Datadog GitHub repository name | `string` | `"datadog-serverless-functions"` | no |
| <a name="input_dd_tags_map"></a> [dd\_tags\_map](#input\_dd\_tags\_map) | A map of Datadog tags to apply to all logs forwarded to Datadog | `map(string)` | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_forwarder_lambda_datadog_host"></a> [forwarder\_lambda\_datadog\_host](#input\_forwarder\_lambda\_datadog\_host) | Datadog Site to send data to. Possible values are `datadoghq.com`, `datadoghq.eu`, `us3.datadoghq.com` and `ddog-gov.com` | `string` | `"datadoghq.com"` | no |
| <a name="input_forwarder_lambda_debug_enabled"></a> [forwarder\_lambda\_debug\_enabled](#input\_forwarder\_lambda\_debug\_enabled) | Whether to enable or disable debug for the Lambda forwarder | `bool` | `false` | no |
| <a name="input_forwarder_log_artifact_url"></a> [forwarder\_log\_artifact\_url](#input\_forwarder\_log\_artifact\_url) | The URL for the code of the Datadog forwarder for Logs. It can be a local file, URL or git repo | `string` | `null` | no |
| <a name="input_forwarder_log_enabled"></a> [forwarder\_log\_enabled](#input\_forwarder\_log\_enabled) | Flag to enable or disable Datadog log forwarder | `bool` | `false` | no |
| <a name="input_forwarder_log_layers"></a> [forwarder\_log\_layers](#input\_forwarder\_log\_layers) | List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog log forwarder lambda function | `list(string)` | `[]` | no |
| <a name="input_forwarder_log_retention_days"></a> [forwarder\_log\_retention\_days](#input\_forwarder\_log\_retention\_days) | Number of days to retain Datadog forwarder lambda execution logs. One of [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653] | `number` | `14` | no |
| <a name="input_forwarder_rds_artifact_url"></a> [forwarder\_rds\_artifact\_url](#input\_forwarder\_rds\_artifact\_url) | The URL for the code of the Datadog forwarder for RDS. It can be a local file, url or git repo | `string` | `null` | no |
| <a name="input_forwarder_rds_enabled"></a> [forwarder\_rds\_enabled](#input\_forwarder\_rds\_enabled) | Flag to enable or disable Datadog RDS enhanced monitoring forwarder | `bool` | `false` | no |
| <a name="input_forwarder_rds_filter_pattern"></a> [forwarder\_rds\_filter\_pattern](#input\_forwarder\_rds\_filter\_pattern) | Filter pattern for Lambda forwarder RDS | `string` | `""` | no |
| <a name="input_forwarder_rds_layers"></a> [forwarder\_rds\_layers](#input\_forwarder\_rds\_layers) | List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog RDS enhanced monitoring lambda function | `list(string)` | `[]` | no |
| <a name="input_forwarder_vpc_logs_artifact_url"></a> [forwarder\_vpc\_logs\_artifact\_url](#input\_forwarder\_vpc\_logs\_artifact\_url) | The URL for the code of the Datadog forwarder for VPC Logs. It can be a local file, url or git repo | `string` | `null` | no |
| <a name="input_forwarder_vpc_logs_enabled"></a> [forwarder\_vpc\_logs\_enabled](#input\_forwarder\_vpc\_logs\_enabled) | Flag to enable or disable Datadog VPC flow log forwarder | `bool` | `false` | no |
| <a name="input_forwarder_vpc_logs_layers"></a> [forwarder\_vpc\_logs\_layers](#input\_forwarder\_vpc\_logs\_layers) | List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog VPC flow log forwarder lambda function | `list(string)` | `[]` | no |
| <a name="input_forwarder_vpclogs_filter_pattern"></a> [forwarder\_vpclogs\_filter\_pattern](#input\_forwarder\_vpclogs\_filter\_pattern) | Filter pattern for Lambda forwarder VPC Logs | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Optional KMS key ID to encrypt Datadog Lambda function logs | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lambda_policy_source_json"></a> [lambda\_policy\_source\_json](#input\_lambda\_policy\_source\_json) | Additional IAM policy document that can optionally be passed and merged with the created policy document | `string` | `""` | no |
| <a name="input_lambda_reserved_concurrent_executions"></a> [lambda\_reserved\_concurrent\_executions](#input\_lambda\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for the lambda function. A value of 0 disables Lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1 | `number` | `-1` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Runtime environment for Datadog Lambda | `string` | `"python3.7"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_s3_bucket_kms_arns"></a> [s3\_bucket\_kms\_arns](#input\_s3\_bucket\_kms\_arns) | List of KMS key ARNs for s3 bucket encryption | `list(string)` | `[]` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | The names and ARNs of S3 buckets to forward logs to Datadog | `list(string)` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to use when the Lambda Function runs in a VPC | `list(string)` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to use when deploying the Lambda Function in a VPC | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_tracing_config_mode"></a> [tracing\_config\_mode](#input\_tracing\_config\_mode) | Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service | `string` | `"PassThrough"` | no |
| <a name="input_vpclogs_cloudwatch_log_group"></a> [vpclogs\_cloudwatch\_log\_group](#input\_vpclogs\_cloudwatch\_log\_group) | The name of the CloudWatch Log Group for VPC flow logs | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_forwarder_log_function_arn"></a> [lambda\_forwarder\_log\_function\_arn](#output\_lambda\_forwarder\_log\_function\_arn) | Datadog Lambda forwarder CloudWatch/S3 function ARN |
| <a name="output_lambda_forwarder_log_function_name"></a> [lambda\_forwarder\_log\_function\_name](#output\_lambda\_forwarder\_log\_function\_name) | Datadog Lambda forwarder CloudWatch/S3 function name |
| <a name="output_lambda_forwarder_rds_enhanced_monitoring_function_name"></a> [lambda\_forwarder\_rds\_enhanced\_monitoring\_function\_name](#output\_lambda\_forwarder\_rds\_enhanced\_monitoring\_function\_name) | Datadog Lambda forwarder RDS Enhanced Monitoring function name |
| <a name="output_lambda_forwarder_rds_function_arn"></a> [lambda\_forwarder\_rds\_function\_arn](#output\_lambda\_forwarder\_rds\_function\_arn) | Datadog Lambda forwarder RDS Enhanced Monitoring function ARN |
| <a name="output_lambda_forwarder_vpc_log_function_arn"></a> [lambda\_forwarder\_vpc\_log\_function\_arn](#output\_lambda\_forwarder\_vpc\_log\_function\_arn) | Datadog Lambda forwarder VPC Flow Logs function ARN |
| <a name="output_lambda_forwarder_vpc_log_function_name"></a> [lambda\_forwarder\_vpc\_log\_function\_name](#output\_lambda\_forwarder\_vpc\_log\_function\_name) | Datadog Lambda forwarder VPC Flow Logs function name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* Datadog's [documentation about provisioning keys](https://docs.datadoghq.com/account_management/api-app-keys
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/datadog-lambda-forwarder) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
