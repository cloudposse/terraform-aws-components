---
tags:
  - component/glue/job
  - layer/unassigned
  - provider/aws
---

# Component: `glue/job`

This component provisions Glue jobs.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    glue/job/example:
      metadata:
        component: glue/job
      vars:
        enabled: true
        name: example
        job_description: Glue job example
        glue_version: "2.0"
        worker_type: Standard
        number_of_workers: 2
        max_retries: 2
        timeout: 20
        glue_iam_component_name: "glue/iam"
        glue_job_s3_bucket_component_name: "s3/datalake"
        glue_job_s3_bucket_script_path: "glue/glue_job.py"
        glue_job_command_name: glueetl
        glue_job_command_python_version: 3
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
| <a name="module_glue_iam_role"></a> [glue\_iam\_role](#module\_glue\_iam\_role) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_glue_job"></a> [glue\_job](#module\_glue\_job) | cloudposse/glue/aws//modules/glue-job | 0.4.0 |
| <a name="module_glue_job_s3_bucket"></a> [glue\_job\_s3\_bucket](#module\_glue\_job\_s3\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.glue_job_aws_tools_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.glue_jobs_aws_tools_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue_redshift_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.glue_job_aws_tools_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_command"></a> [command](#input\_command) | The command of the job | `map(any)` | `null` | no |
| <a name="input_connections"></a> [connections](#input\_connections) | The list of connections used for this job | `list(string)` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_arguments"></a> [default\_arguments](#input\_default\_arguments) | The map of default arguments for the job. You can specify arguments here that your own job-execution script consumes, as well as arguments that AWS Glue itself consumes | `map(string)` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_execution_property"></a> [execution\_property](#input\_execution\_property) | Execution property of the job | <pre>object({<br>    # The maximum number of concurrent runs allowed for the job. The default is 1.<br>    max_concurrent_runs = number<br>  })</pre> | `null` | no |
| <a name="input_glue_iam_component_name"></a> [glue\_iam\_component\_name](#input\_glue\_iam\_component\_name) | Glue IAM component name. Used to get the Glue IAM role from the remote state | `string` | `"glue/iam"` | no |
| <a name="input_glue_job_command_name"></a> [glue\_job\_command\_name](#input\_glue\_job\_command\_name) | The name of the job command. Defaults to glueetl. Use pythonshell for Python Shell Job Type, or gluestreaming for Streaming Job Type. max\_capacity needs to be set if pythonshell is chosen | `string` | `"glueetl"` | no |
| <a name="input_glue_job_command_python_version"></a> [glue\_job\_command\_python\_version](#input\_glue\_job\_command\_python\_version) | The Python version being used to execute a Python shell job. Allowed values are 2, 3 or 3.9. Version 3 refers to Python 3.6 | `number` | `3` | no |
| <a name="input_glue_job_s3_bucket_component_name"></a> [glue\_job\_s3\_bucket\_component\_name](#input\_glue\_job\_s3\_bucket\_component\_name) | Glue job S3 bucket component name. Used to get the remote state of the S3 bucket where the Glue job script is located | `string` | `null` | no |
| <a name="input_glue_job_s3_bucket_script_path"></a> [glue\_job\_s3\_bucket\_script\_path](#input\_glue\_job\_s3\_bucket\_script\_path) | Glue job script path in the S3 bucket | `string` | `null` | no |
| <a name="input_glue_version"></a> [glue\_version](#input\_glue\_version) | The version of Glue to use | `string` | `"2.0"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_job_description"></a> [job\_description](#input\_job\_description) | Glue job description | `string` | `null` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | Glue job name. If not provided, the name will be generated from the context | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum number of AWS Glue data processing units (DPUs) that can be allocated when the job runs. Required when `pythonshell` is set, accept either 0.0625 or 1.0. Use `number_of_workers` and `worker_type` arguments instead with `glue_version` 2.0 and above | `number` | `null` | no |
| <a name="input_max_retries"></a> [max\_retries](#input\_max\_retries) | The maximum number of times to retry the job if it fails | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_non_overridable_arguments"></a> [non\_overridable\_arguments](#input\_non\_overridable\_arguments) | Non-overridable arguments for this job, specified as name-value pairs | `map(string)` | `null` | no |
| <a name="input_notification_property"></a> [notification\_property](#input\_notification\_property) | Notification property of the job | <pre>object({<br>    # After a job run starts, the number of minutes to wait before sending a job run delay notification<br>    notify_delay_after = number<br>  })</pre> | `null` | no |
| <a name="input_number_of_workers"></a> [number\_of\_workers](#input\_number\_of\_workers) | The number of workers of a defined `worker_type` that are allocated when a job runs | `number` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_security_configuration"></a> [security\_configuration](#input\_security\_configuration) | The name of the Security Configuration to be associated with the job | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The job timeout in minutes. The default is 2880 minutes (48 hours) for `glueetl` and `pythonshell` jobs, and `null` (unlimited) for `gluestreaming` jobs | `number` | `2880` | no |
| <a name="input_worker_type"></a> [worker\_type](#input\_worker\_type) | The type of predefined worker that is allocated when a job runs. Accepts a value of `Standard`, `G.1X`, or `G.2X` | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_job_arn"></a> [job\_arn](#output\_job\_arn) | Glue job ARN |
| <a name="output_job_id"></a> [job\_id](#output\_job\_id) | Glue job ID |
| <a name="output_job_name"></a> [job\_name](#output\_job\_name) | Glue job name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/glue/job) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
